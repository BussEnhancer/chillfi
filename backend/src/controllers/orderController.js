const pool = require('../db/pool');
const { getShippingFee, checkoutServiceability } = require('../utils/shipping');
const { openAutoRefund } = require('../utils/refunds');
const { getIncludedGst } = require('../utils/tax');
const shiprocket = require('../utils/shiprocket');
const shipments = require('../services/shipmentService');
const { notifyUser } = require('../utils/notify');

const generateOrderNumber = () => {
  const ts = Date.now().toString().slice(-6);
  const rand = Math.floor(Math.random() * 9000 + 1000);
  return `CF${ts}${rand}`;
};

// POST /api/orders
const createOrder = async (req, res) => {
  const { address_id, payment_method = 'COD', coupon_id: rawCouponId, coupon_code, notes } = req.body;
  if (!address_id) return res.status(400).json({ success: false, message: 'Delivery address required' });

  // Resolve coupon: accept either coupon_id (UUID) or coupon_code (string from Flutter)
  let coupon_id = rawCouponId;
  if (!coupon_id && coupon_code) {
    const lookup = await pool.query('SELECT id FROM coupons WHERE UPPER(code) = UPPER($1) AND is_active = TRUE', [coupon_code]);
    if (!lookup.rows.length) return res.status(400).json({ success: false, message: 'This coupon is invalid or has expired. Please remove it and try again.' });
    coupon_id = lookup.rows[0].id;
  }

  // Verify address belongs to user
  const addr = await pool.query('SELECT id, pincode FROM addresses WHERE id = $1 AND user_id = $2', [address_id, req.user.id]);
  if (!addr.rows.length) return res.status(400).json({ success: false, message: 'Invalid address' });

  // Delivery serviceability (only block when Delhivery definitively says no; unknown never blocks).
  const svc = await checkoutServiceability(addr.rows[0].pincode);
  if (svc.serviceable === false) {
    return res.status(400).json({ success: false, message: `Sorry, we can't deliver to pincode ${addr.rows[0].pincode} yet. Please choose another address.` });
  }
  if (String(payment_method).toUpperCase() === 'COD' && (svc.cod_blocked || (svc.serviceable === true && svc.cod === false))) {
    return res.status(400).json({ success: false, message: svc.cod_reason === 'store'
      ? 'Pay on Delivery is currently unavailable. Please pay online.'
      : 'Pay on Delivery isn\'t available for this pincode. Please pay online.' });
  }

  // Get cart items
  const cartResult = await pool.query('SELECT id FROM cart WHERE user_id = $1', [req.user.id]);
  if (!cartResult.rows.length) return res.status(400).json({ success: false, message: 'Cart is empty' });

  const cartId = cartResult.rows[0].id;
  const items = await pool.query(`
    SELECT ci.quantity, p.id as product_id, p.name, p.price, p.old_price, p.stock, p.status,
      (SELECT url FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as image
    FROM cart_items ci JOIN products p ON ci.product_id = p.id
    WHERE ci.cart_id = $1
  `, [cartId]);

  if (!items.rows.length) return res.status(400).json({ success: false, message: 'Cart is empty' });

  // Fast pre-check (not authoritative — re-checked under lock inside the transaction below)
  for (const item of items.rows) {
    // Defence in depth: a non-positive quantity would lower the total and *increase* stock.
    if (!Number.isInteger(item.quantity) || item.quantity < 1) {
      return res.status(400).json({ success: false, message: `Please update the quantity of "${item.name}" in your cart.` });
    }
    if (item.status === 'Inactive' || item.status === 'Out of Stock') {
      return res.status(400).json({ success: false, message: `"${item.name}" is no longer available. Please remove it from your cart.` });
    }
    if (item.stock < item.quantity) {
      return res.status(400).json({ success: false, message: `"${item.name}" has only ${item.stock} units left` });
    }
  }

  const subtotal = items.rows.reduce((s, i) => s + parseFloat(i.price) * i.quantity, 0);
  const deliveryFee = await getShippingFee(addr.rows[0].pincode, subtotal);
  let discount = 0;

  // Apply coupon
  if (coupon_id) {
    const coupon = await pool.query('SELECT * FROM coupons WHERE id = $1 AND is_active = TRUE', [coupon_id]);
    // Re-validate every rule here: the order endpoint must not rely on the client having called apply-coupon.
    if (!coupon.rows.length) {
      return res.status(400).json({ success: false, message: 'This coupon is invalid or has expired. Please remove it and try again.' });
    }
    {
      const c = coupon.rows[0];
      if (c.expires_at && new Date(c.expires_at) <= new Date()) {
        return res.status(400).json({ success: false, message: 'This coupon has expired. Please remove it and try again.' });
      }
      if (subtotal < parseFloat(c.min_order || 0)) {
        return res.status(400).json({ success: false, message: `Add items worth ₹${Math.round(Number(c.min_order)).toLocaleString('en-IN')} or more to use this coupon` });
      }
      const used = await pool.query('SELECT 1 FROM coupon_usage WHERE coupon_id = $1 AND user_id = $2', [c.id, req.user.id]);
      if (used.rows.length) {
        return res.status(400).json({ success: false, message: "You've already used this coupon." });
      }
      if (c.type === 'Percentage') {
        discount = (subtotal * c.value) / 100;
        if (c.max_discount > 0) discount = Math.min(discount, c.max_discount);
      } else if (c.type === 'Flat') {
        discount = c.value;
      } else if (c.type === 'Free Shipping') {
        discount = deliveryFee;
      }
      discount = Math.min(parseFloat(discount) || 0, subtotal + deliveryFee); // never below zero
    }
  }

  // GST-inclusive prices: tax_amount is the GST already contained in the (post-coupon) item value.
  const taxAmount = await getIncludedGst(subtotal - discount);
  const total = parseFloat((subtotal + deliveryFee - discount).toFixed(2));
  const orderNumber = generateOrderNumber();

  // Create order in transaction
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // Lock the product rows being ordered so concurrent orders can't both pass the stock check
    const productIds = items.rows.map((i) => i.product_id);
    const lockedStock = await client.query(
      'SELECT id, stock FROM products WHERE id = ANY($1::uuid[]) FOR UPDATE',
      [productIds]
    );
    const stockById = new Map(lockedStock.rows.map((r) => [r.id, r.stock]));
    for (const item of items.rows) {
      const currentStock = stockById.get(item.product_id) ?? 0;
      if (currentStock < item.quantity) {
        await client.query('ROLLBACK');
        return res.status(400).json({ success: false, message: `"${item.name}" has only ${currentStock} units left` });
      }
    }

    // Lock the coupon row too, so concurrent orders can't both pass the usage_limit check
    if (coupon_id) {
      const lockedCoupon = await client.query(
        'SELECT used_count, usage_limit FROM coupons WHERE id = $1 AND is_active = TRUE FOR UPDATE',
        [coupon_id]
      );
      if (lockedCoupon.rows.length) {
        const { used_count, usage_limit } = lockedCoupon.rows[0];
        if (usage_limit > 0 && used_count >= usage_limit) {
          await client.query('ROLLBACK');
          return res.status(400).json({ success: false, message: 'This coupon has reached its usage limit' });
        }
      }
    }

    const orderResult = await client.query(`
      INSERT INTO orders (order_number, user_id, address_id, subtotal, discount, delivery_fee, tax_amount, total,
        coupon_id, payment_method, payment_status, status, notes, shipping_status)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,'Processing',$12,'pending') RETURNING *
    `, [orderNumber, req.user.id, address_id, subtotal, discount, deliveryFee, taxAmount, total,
      coupon_id || null, payment_method,
      payment_method === 'COD' ? 'Pending' : 'Pending', notes || null]);

    const order = orderResult.rows[0];

    // Insert order items + reduce stock (guarded WHERE as a final safety net against negative stock)
    for (const item of items.rows) {
      await client.query(`
        INSERT INTO order_items (order_id, product_id, product_name, product_image, price, quantity)
        VALUES ($1,$2,$3,$4,$5,$6)
      `, [order.id, item.product_id, item.name, item.image, item.price, item.quantity]);

      const stockUpdate = await client.query(
        'UPDATE products SET stock = stock - $1 WHERE id = $2 AND stock >= $1 RETURNING stock',
        [item.quantity, item.product_id]
      );
      if (!stockUpdate.rows.length) {
        await client.query('ROLLBACK');
        return res.status(400).json({ success: false, message: `"${item.name}" is out of stock` });
      }
    }

    // Mark coupon used
    if (coupon_id) {
      await client.query(
        'INSERT INTO coupon_usage (coupon_id, user_id, order_id) VALUES ($1,$2,$3) ON CONFLICT DO NOTHING',
        [coupon_id, req.user.id, order.id]
      );
      await client.query('UPDATE coupons SET used_count = used_count + 1 WHERE id = $1', [coupon_id]);
    }

    // Clear cart
    await client.query('DELETE FROM cart_items WHERE cart_id = $1', [cartId]);

    await client.query('COMMIT');

    res.status(201).json({
      success: true,
      message: 'Order placed successfully!',
      data: { order: { ...order, items: items.rows } },
    });

    // Post-commit side effects (never affect the placed order)
    console.log(`[order] placed ${order.order_number} user=${req.user.id} method=${payment_method} total=${total}`);
    // Prepaid orders are confirmed + shipped from the payment-success path (paymentController).
    if (payment_method === 'COD') {
      shipments.notifyOrderConfirmed(order);
      shipments.maybeAutoShip(order.id, 'cod-order');
    }
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
};

// GET /api/orders
const getOrders = async (req, res) => {
  const { status, page = 1, limit = 10, search } = req.query;
  const offset = (page - 1) * limit;
  const values = [req.user.id];
  let statusFilter = '';
  if (status && status !== 'all') {
    values.push(status);
    statusFilter = `AND o.status = $${values.length}`;
  }
  // Search across ALL of the customer's orders (order number or product name), not just the current page.
  if (search && String(search).trim()) {
    values.push(`%${String(search).trim()}%`);
    statusFilter += ` AND (o.order_number ILIKE $${values.length} OR EXISTS (
      SELECT 1 FROM order_items si WHERE si.order_id = o.id AND si.product_name ILIKE $${values.length}))`;
  }

  const result = await pool.query(`
    SELECT o.*,
      (SELECT json_agg(json_build_object(
        'product_name', oi.product_name, 'product_image', oi.product_image,
        'price', oi.price, 'quantity', oi.quantity
      )) FROM order_items oi WHERE oi.order_id = o.id) as items
    FROM orders o
    WHERE o.user_id = $1 ${statusFilter}
    ORDER BY o.created_at DESC
    LIMIT $${values.length + 1} OFFSET $${values.length + 2}
  `, [...values, limit, offset]);

  const count = await pool.query(
    `SELECT COUNT(*) FROM orders o WHERE o.user_id = $1 ${statusFilter}`,
    values
  );

  res.json({
    success: true,
    data: {
      orders: result.rows,
      total: parseInt(count.rows[0].count),
      page: parseInt(page),
      pages: Math.ceil(count.rows[0].count / limit),
    },
  });
};

// GET /api/orders/:id
const getOrder = async (req, res) => {
  const { id } = req.params;
  const result = await pool.query(`
    SELECT o.*, a.name as addr_name, a.phone as addr_phone, a.line1, a.line2,
      a.city, a.state, a.pincode, a.label as addr_label,
      COALESCE(o.shipment_provider, 'delhivery') as shipment_provider
    FROM orders o
    LEFT JOIN addresses a ON o.address_id = a.id
    WHERE o.id = $1 AND o.user_id = $2
  `, [id, req.user.id]);

  if (!result.rows.length) return res.status(404).json({ success: false, message: 'Order not found' });

  const items = await pool.query('SELECT * FROM order_items WHERE order_id = $1', [id]);
  const refundRequest = await pool.query(
    'SELECT * FROM refund_requests WHERE order_id = $1 ORDER BY created_at DESC LIMIT 1',
    [id]
  );
  res.json({
    success: true,
    data: { order: { ...result.rows[0], items: items.rows, refund_request: refundRequest.rows[0] || null } },
  });
};

// POST /api/orders/:id/refund-request
const requestRefund = async (req, res) => {
  const { id } = req.params;
  const { type = 'Refund', reason } = req.body;
  if (!reason || !reason.trim()) return res.status(400).json({ success: false, message: 'Reason is required' });
  if (!['Refund', 'Return', 'Exchange'].includes(type)) {
    return res.status(400).json({ success: false, message: 'Invalid request type' });
  }

  const order = await pool.query('SELECT id, status, total, payment_status FROM orders WHERE id = $1 AND user_id = $2', [id, req.user.id]);
  if (!order.rows.length) return res.status(404).json({ success: false, message: 'Order not found' });
  if (!['Delivered', 'Cancelled'].includes(order.rows[0].status)) {
    return res.status(400).json({ success: false, message: 'Refund/return can only be requested for delivered or cancelled orders' });
  }
  if (order.rows[0].status === 'Cancelled') {
    if (order.rows[0].payment_status !== 'Paid') {
      return res.status(400).json({ success: false, message: 'Nothing was charged for this order, so no refund is needed.' });
    }
    if (type !== 'Refund') {
      return res.status(400).json({ success: false, message: 'Cancelled orders can only be refunded.' });
    }
  }

  const existing = await pool.query(
    `SELECT id FROM refund_requests WHERE order_id = $1 AND status IN ('Requested', 'Approved')`,
    [id]
  );
  if (existing.rows.length) {
    return res.status(400).json({ success: false, message: 'A request is already pending for this order' });
  }

  const result = await pool.query(
    `INSERT INTO refund_requests (order_id, user_id, type, reason, refund_amount)
     VALUES ($1, $2, $3, $4, $5) RETURNING *`,
    [id, req.user.id, type, reason.trim(), order.rows[0].total]
  );
  res.status(201).json({ success: true, message: 'Request submitted', data: result.rows[0] });
};

// A cancelled order that was already paid online must be refunded — open the refund request automatically
// (idempotent) so it shows up in Admin → Refunds instead of relying on the customer to ask.
// POST /api/orders/:id/cancel
const cancelOrder = async (req, res) => {
  const { id } = req.params;
  const { reason } = req.body;

  const result = await pool.query(
    `SELECT * FROM orders WHERE id = $1 AND user_id = $2`,
    [id, req.user.id]
  );

  if (!result.rows.length) return res.status(404).json({ success: false, message: 'Order not found' });
  if (result.rows[0].status === 'Delivered') {
    return res.status(400).json({ success: false, message: 'Delivered orders cannot be cancelled' });
  }
  if (result.rows[0].status === 'Cancelled') {
    return res.status(400).json({ success: false, message: 'Order already cancelled' });
  }

  // Cancel the courier shipment first; refuse if it has already been picked up.
  try {
    await shipments.cancelShipmentForOrder(result.rows[0], { by: 'customer' });
  } catch (err) {
    // 409 = already picked up (message is customer-friendly). Anything else is a courier/API failure:
    // log it, but show the customer a clear message instead of the technical cause.
    if (err.status === 409) return res.status(409).json({ success: false, message: err.message });
    console.error(`[order] cancel failed order=${id}: ${err.message}`);
    return res.status(502).json({ success: false, message: "We couldn't cancel your order right now. Please try again in a few minutes or contact support." });
  }

  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const upd = await client.query(
      `UPDATE orders SET status = 'Cancelled', notes = COALESCE($1, notes), updated_at = NOW()
       WHERE id = $2 AND status NOT IN ('Cancelled', 'Delivered') RETURNING id`,
      [reason, id]
    );
    if (!upd.rows.length) {
      await client.query('ROLLBACK');
      return res.status(409).json({ success: false, message: 'Order status changed; please refresh' });
    }
    const items = await client.query('SELECT product_id, quantity FROM order_items WHERE order_id = $1', [id]);
    for (const item of items.rows) {
      await client.query('UPDATE products SET stock = stock + $1 WHERE id = $2', [item.quantity, item.product_id]);
    }
    await openAutoRefund(client, result.rows[0], `Order cancelled by customer${reason ? `: ${reason}` : ''}`);
    await client.query('COMMIT');
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }

  // An unpaid online order was never confirmed to the customer (they just saw payment fail) — no "cancelled" notice.
  const neverConfirmed = result.rows[0].payment_method !== 'COD' && result.rows[0].payment_status !== 'Paid';
  if (!neverConfirmed) notifyUser(req.user.id, {
    title: 'Order cancelled',
    body: `Your order ${result.rows[0].order_number} has been cancelled.`,
    data: { order_id: id, order_number: result.rows[0].order_number },
    dedupeKey: `order:${id}:cancelled`,
    storeSettingKey: 'notify_order_cancelled',
  });
  res.json({ success: true, message: 'Order cancelled successfully' });
};

// ── ADMIN ──────────────────────────────────────────────────

// GET /api/admin/orders
const adminGetOrders = async (req, res) => {
  const { status, page = 1, search } = req.query;
  const limit = Math.max(1, Math.min(1000, parseInt(req.query.limit) || 20));
  const offset = (page - 1) * limit;
  const values = [];
  const conditions = [];

  if (status && status !== 'all') { values.push(status); conditions.push(`o.status = $${values.length}`); }
  if (search) {
    values.push(`%${search}%`);
    conditions.push(`(o.order_number ILIKE $${values.length} OR u.name ILIKE $${values.length} OR u.phone ILIKE $${values.length})`);
  }

  const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

  const result = await pool.query(`
    SELECT o.*, u.name as customer_name, u.phone as customer_phone, u.email as customer_email,
      a.label as address_label, a.name as address_name, a.phone as address_phone,
      a.line1 as address_line1, a.line2 as address_line2, a.city as address_city,
      a.state as address_state, a.pincode as address_pincode,
      (SELECT product_name FROM order_items WHERE order_id = o.id LIMIT 1) as product,
      (SELECT COALESCE(SUM(quantity),0) FROM order_items WHERE order_id = o.id) as item_count,
      (SELECT COUNT(*) FROM order_items WHERE order_id = o.id) as line_count,
      (SELECT product_image FROM order_items WHERE order_id = o.id LIMIT 1) as img
    FROM orders o
    JOIN users u ON o.user_id = u.id
    LEFT JOIN addresses a ON a.id = o.address_id
    ${where}
    ORDER BY o.created_at DESC
    LIMIT $${values.length + 1} OFFSET $${values.length + 2}
  `, [...values, limit, offset]);

  const count = await pool.query(
    `SELECT COUNT(*) FROM orders o JOIN users u ON o.user_id = u.id ${where}`,
    values
  );

  res.json({
    success: true,
    data: {
      orders: result.rows,
      total: parseInt(count.rows[0].count),
      page: parseInt(page),
      pages: Math.ceil(count.rows[0].count / limit),
    },
  });
};

// PUT /api/admin/orders/:id/status
// Manual override. Normally status is driven by Delhivery events; this stays for
// exceptions (e.g. courier data missing) and is recorded in shipment_events.
const MANUAL_STATE = { Shipped: 'in_transit', Delivered: 'delivered', Cancelled: 'cancelled' };
const adminUpdateStatus = async (req, res) => {
  const { id } = req.params;
  const { status, tracking_id } = req.body;
  const allowed = ['Processing', 'Shipped', 'Delivered', 'Cancelled'];
  if (!allowed.includes(status)) {
    return res.status(400).json({ success: false, message: 'Invalid status' });
  }

  const current = await pool.query('SELECT * FROM orders WHERE id = $1', [id]);
  if (!current.rows.length) return res.status(404).json({ success: false, message: 'Order not found' });
  const before = current.rows[0];

  // Terminal states cannot be reopened (returns/refunds go through Admin → Refunds).
  if (status !== before.status && ['Cancelled', 'Delivered'].includes(before.status)) {
    return res.status(400).json({ success: false, message: `A ${before.status.toLowerCase()} order can't be changed to ${status}.` });
  }

  if (status === 'Cancelled' && before.status !== 'Cancelled') {
    try {
      await shipments.cancelShipmentForOrder(before, { by: 'admin' });
    } catch (err) {
      return res.status(err.status || 500).json({ success: false, message: err.message });
    }
  }

  const result = await pool.query(`
    UPDATE orders SET status = $1::varchar, tracking_id = COALESCE($2, tracking_id),
      payment_status = CASE WHEN $1::varchar = 'Delivered' THEN 'Paid' ELSE payment_status END,
      delivered_at = CASE WHEN $1::varchar = 'Delivered' THEN COALESCE(delivered_at, NOW()) ELSE delivered_at END,
      updated_at = NOW()
    WHERE id = $3 RETURNING *
  `, [status, tracking_id || null, id]);
  const order = result.rows[0];

  if (status === 'Cancelled' && before.status !== 'Cancelled') {
    // Put the stock back and open a refund for prepaid orders (same as a customer cancellation).
    const items = await pool.query('SELECT product_id, quantity FROM order_items WHERE order_id = $1', [id]);
    for (const item of items.rows) {
      await pool.query('UPDATE products SET stock = stock + $1 WHERE id = $2', [item.quantity, item.product_id]);
    }
    await openAutoRefund(pool, before, 'Order cancelled by store');
  }

  if (status !== before.status) {
    console.log(`[order] admin ${req.user.id} set ${order.order_number} ${before.status} → ${status}`);
    if (order.tracking_id) {
      await pool.query(`
        INSERT INTO shipment_events (order_id, awb, source, status, instructions, event_time, applied, dedupe_key)
        VALUES ($1,$2,'admin',$3,$4,NOW(),TRUE,$5) ON CONFLICT (dedupe_key) DO NOTHING`,
        [id, order.tracking_id, status, `Status set manually by admin`, `${order.tracking_id}|admin|${status}|${Date.now()}`]);
    }
    const state = MANUAL_STATE[status];
    if (state) await shipments.sendStatusNotification(order, state);
  }
  res.json({ success: true, data: { order } });
};

// GET /api/admin/refunds
const adminGetRefunds = async (req, res) => {
  const { status, page = 1, limit = 20 } = req.query;
  const offset = (page - 1) * limit;
  const values = [];
  let where = '';
  if (status && status !== 'all') { values.push(status); where = `WHERE rr.status = $${values.length}`; }

  const [rows, count] = await Promise.all([
    pool.query(`
      SELECT rr.*, o.order_number, o.total as order_total, o.status as order_status,
        u.name as customer_name, u.phone as customer_phone, u.email as customer_email
      FROM refund_requests rr
      JOIN orders o ON rr.order_id = o.id
      LEFT JOIN users u ON rr.user_id = u.id
      ${where}
      ORDER BY rr.created_at DESC
      LIMIT $${values.length + 1} OFFSET $${values.length + 2}
    `, [...values, limit, offset]),
    pool.query(`SELECT COUNT(*) FROM refund_requests rr ${where}`, values),
  ]);

  res.json({ success: true, data: { requests: rows.rows, total: parseInt(count.rows[0].count) } });
};

// PUT /api/admin/refunds/:id
const adminUpdateRefund = async (req, res) => {
  const { id } = req.params;
  const { status, refund_amount, admin_notes } = req.body;
  const allowed = ['Requested', 'Approved', 'Rejected', 'Refunded'];
  if (!allowed.includes(status)) return res.status(400).json({ success: false, message: 'Invalid status' });
  const cur = await pool.query('SELECT status FROM refund_requests WHERE id = $1', [id]);
  if (!cur.rows.length) return res.status(404).json({ success: false, message: 'Request not found' });
  if (cur.rows[0].status === 'Refunded' && status !== 'Refunded') {
    return res.status(400).json({ success: false, message: 'This request is already refunded and cannot be changed.' });
  }

  const result = await pool.query(
    `UPDATE refund_requests SET status = $1, refund_amount = COALESCE($2, refund_amount),
       admin_notes = COALESCE($3, admin_notes), updated_at = NOW()
     WHERE id = $4 RETURNING *`,
    [status, refund_amount ?? null, admin_notes || null, id]
  );
  if (!result.rows.length) return res.status(404).json({ success: false, message: 'Request not found' });

  if (status === 'Refunded') {
    await pool.query(`UPDATE orders SET payment_status = 'Refunded', updated_at = NOW() WHERE id = $1`, [result.rows[0].order_id]);
  }

  // Tell the customer when their request moves (in-app + push).
  if (status !== cur.rows[0].status) {
    const rr = result.rows[0];
    const o = (await pool.query('SELECT order_number, user_id FROM orders WHERE id = $1', [rr.order_id])).rows[0];
    const text = {
      Approved: `Your ${rr.type.toLowerCase()} request for order ${o?.order_number} has been approved.`,
      Rejected: `Your ${rr.type.toLowerCase()} request for order ${o?.order_number} was not approved.${rr.admin_notes ? ` Note: ${rr.admin_notes}` : ''}`,
      Refunded: `Your refund of ₹${Number(rr.refund_amount || 0).toLocaleString('en-IN')} for order ${o?.order_number} has been processed. It usually reaches you in 5–7 business days.`,
    }[status];
    if (o && text) {
      notifyUser(o.user_id, {
        title: status === 'Refunded' ? 'Refund processed' : `${rr.type} request ${status.toLowerCase()}`,
        body: text,
        data: { order_id: rr.order_id, order_number: o.order_number, refund_status: status },
        dedupeKey: `refund:${rr.id}:${status}`,
      }).catch(() => {});
    }
  }

  res.json({ success: true, message: 'Request updated', data: result.rows[0] });
};

// POST /api/admin/orders/:id/ship — create (or retry) the Delhivery shipment.
// Body: { provider?: 'delhivery' | 'shiprocket' } — defaults to Delhivery.
const adminShipOrder = async (req, res, next) => {
  try {
    const { id } = req.params;
    const provider = (req.body?.provider || 'delhivery').toLowerCase();
    if (!['shiprocket', 'delhivery'].includes(provider)) {
      return res.status(400).json({ success: false, message: 'Invalid provider. Use "delhivery" or "shiprocket".' });
    }

    if (provider === 'shiprocket') {
      const order = await shipments.loadOrderForShipment(id);
      if (!order) return res.status(404).json({ success: false, message: 'Order not found' });
      if (order.tracking_id) return res.status(400).json({ success: false, message: `Shipment already created. AWB/Waybill: ${order.tracking_id}` });
      const awb = await shiprocket.createShipmentOrder({ ...order, address: { ...order.address, street: order.address.line1 } });
      await pool.query(`UPDATE orders SET tracking_id = $1, shipment_provider = 'shiprocket', status = 'Shipped', updated_at = NOW() WHERE id = $2`, [awb, id]);
      return res.json({ success: true, message: 'Shipment created via Shiprocket', data: { awb, provider } });
    }

    const r = await shipments.createShipmentForOrder(id, { trigger: `admin:${req.user.id}` });
    if (!r.ok) {
      return res.status(r.reason ? 400 : 502).json({ success: false, message: r.reason || r.error, data: { code: r.code || null } });
    }
    res.json({
      success: true,
      message: r.recovered ? 'Existing Delhivery shipment linked' : `Shipment created via Delhivery (${r.env})`,
      data: { awb: r.awb, provider: 'delhivery', env: r.env },
    });
  } catch (err) { next(err); }
};

const _trackingFor = async (orderRow) => {
  const provider = (orderRow.shipment_provider || 'delhivery').toLowerCase();
  if (provider === 'shiprocket') return { ...(await shiprocket.trackShipment(orderRow.tracking_id)), provider };
  return shipments.getTrackingView(orderRow.id);
};

// GET /api/admin/orders/:id/tracking — live tracking (admin)
const adminTrackOrder = async (req, res, next) => {
  try {
    const order = await pool.query('SELECT id, tracking_id, shipment_provider FROM orders WHERE id = $1', [req.params.id]);
    if (!order.rows.length) return res.status(404).json({ success: false, message: 'Order not found' });
    if (!order.rows[0].tracking_id) return res.status(400).json({ success: false, message: 'No AWB assigned to this order yet' });
    res.json({ success: true, data: await _trackingFor(order.rows[0]) });
  } catch (err) { next(err); }
};

// GET /api/orders/:id/tracking — customer-facing tracking (DB events, refreshed from Delhivery when stale)
const getOrderTracking = async (req, res, next) => {
  try {
    const order = await pool.query(
      'SELECT id, tracking_id, shipment_provider FROM orders WHERE id = $1 AND user_id = $2',
      [req.params.id, req.user.id]
    );
    if (!order.rows.length) return res.status(404).json({ success: false, message: 'Order not found' });
    if (!order.rows[0].tracking_id) return res.json({ success: true, data: null, message: 'Tracking not available yet' });
    res.json({ success: true, data: await _trackingFor(order.rows[0]) });
  } catch (err) { next(err); }
};

// GET /api/admin/orders/:id/label — Delhivery shipping label (packing slip) for printing
const adminShippingLabel = async (req, res, next) => {
  try {
    const o = (await pool.query('SELECT tracking_id, shipment_provider FROM orders WHERE id = $1', [req.params.id])).rows[0];
    if (!o) return res.status(404).json({ success: false, message: 'Order not found' });
    if (!o.tracking_id || (o.shipment_provider || 'delhivery') !== 'delhivery') {
      return res.status(400).json({ success: false, message: 'No Delhivery shipment for this order yet' });
    }
    const slip = await require('../utils/delhivery').getPackingSlip(o.tracking_id);
    res.json({ success: true, data: slip });
  } catch (err) {
    res.status(err.code === 'NOT_FOUND' ? 404 : 502).json({ success: false, message: err.message });
  }
};

// POST /api/admin/orders/:id/sync-tracking — pull latest status from Delhivery now
const adminSyncTracking = async (req, res, next) => {
  try {
    const summary = await shipments.syncShipments({ orderIds: [req.params.id] });
    const view = await shipments.getTrackingView(req.params.id, { refresh: false });
    res.json({ success: true, data: { summary, tracking: view } });
  } catch (err) { next(err); }
};

module.exports = {
  createOrder, getOrders, getOrder, cancelOrder, requestRefund,
  adminGetOrders, adminUpdateStatus, adminGetRefunds, adminUpdateRefund,
  adminShipOrder, adminTrackOrder, getOrderTracking, adminSyncTracking, adminShippingLabel,
};
