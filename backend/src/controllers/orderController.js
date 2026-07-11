const pool = require('../db/pool');
const { getShippingFee } = require('../utils/shipping');
const { getGstAmount } = require('../utils/tax');
const { createShipment, trackShipment } = require('../utils/delhivery');

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
    const lookup = await pool.query('SELECT id FROM coupons WHERE code = $1 AND is_active = TRUE', [coupon_code]);
    if (lookup.rows.length) coupon_id = lookup.rows[0].id;
  }

  // Verify address belongs to user
  const addr = await pool.query('SELECT id, pincode FROM addresses WHERE id = $1 AND user_id = $2', [address_id, req.user.id]);
  if (!addr.rows.length) return res.status(400).json({ success: false, message: 'Invalid address' });

  // Get cart items
  const cartResult = await pool.query('SELECT id FROM cart WHERE user_id = $1', [req.user.id]);
  if (!cartResult.rows.length) return res.status(400).json({ success: false, message: 'Cart is empty' });

  const cartId = cartResult.rows[0].id;
  const items = await pool.query(`
    SELECT ci.quantity, p.id as product_id, p.name, p.price, p.old_price, p.stock,
      (SELECT url FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as image
    FROM cart_items ci JOIN products p ON ci.product_id = p.id
    WHERE ci.cart_id = $1
  `, [cartId]);

  if (!items.rows.length) return res.status(400).json({ success: false, message: 'Cart is empty' });

  // Fast pre-check (not authoritative — re-checked under lock inside the transaction below)
  for (const item of items.rows) {
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
    if (coupon.rows.length) {
      const c = coupon.rows[0];
      if (c.type === 'Percentage') {
        discount = (subtotal * c.value) / 100;
        if (c.max_discount > 0) discount = Math.min(discount, c.max_discount);
      } else if (c.type === 'Flat') {
        discount = c.value;
      } else if (c.type === 'Free Shipping') {
        discount = deliveryFee;
      }
    }
  }

  const taxAmount = await getGstAmount(subtotal - discount);
  const total = parseFloat((subtotal + deliveryFee - discount + taxAmount).toFixed(2));
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
        coupon_id, payment_method, payment_status, status, notes)
      VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,'Processing',$12) RETURNING *
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
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
};

// GET /api/orders
const getOrders = async (req, res) => {
  const { status, page = 1, limit = 10 } = req.query;
  const offset = (page - 1) * limit;
  const values = [req.user.id];
  let statusFilter = '';
  if (status && status !== 'all') {
    values.push(status);
    statusFilter = `AND o.status = $${values.length}`;
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
      a.city, a.state, a.pincode, a.label as addr_label
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

  const order = await pool.query('SELECT id, status, total FROM orders WHERE id = $1 AND user_id = $2', [id, req.user.id]);
  if (!order.rows.length) return res.status(404).json({ success: false, message: 'Order not found' });
  if (!['Delivered', 'Cancelled'].includes(order.rows[0].status)) {
    return res.status(400).json({ success: false, message: 'Refund/return can only be requested for delivered or cancelled orders' });
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

// POST /api/orders/:id/cancel
const cancelOrder = async (req, res) => {
  const { id } = req.params;
  const { reason } = req.body;

  const result = await pool.query(
    `SELECT status FROM orders WHERE id = $1 AND user_id = $2`,
    [id, req.user.id]
  );

  if (!result.rows.length) return res.status(404).json({ success: false, message: 'Order not found' });
  if (result.rows[0].status === 'Delivered') {
    return res.status(400).json({ success: false, message: 'Delivered orders cannot be cancelled' });
  }
  if (result.rows[0].status === 'Cancelled') {
    return res.status(400).json({ success: false, message: 'Order already cancelled' });
  }

  await pool.query(
    `UPDATE orders SET status = 'Cancelled', notes = COALESCE($1, notes), updated_at = NOW() WHERE id = $2`,
    [reason, id]
  );

  // Restore stock
  const items = await pool.query('SELECT product_id, quantity FROM order_items WHERE order_id = $1', [id]);
  for (const item of items.rows) {
    await pool.query('UPDATE products SET stock = stock + $1 WHERE id = $2', [item.quantity, item.product_id]);
  }

  res.json({ success: true, message: 'Order cancelled successfully' });
};

// ── ADMIN ──────────────────────────────────────────────────

// GET /api/admin/orders
const adminGetOrders = async (req, res) => {
  const { status, page = 1, limit = 20, search } = req.query;
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
const adminUpdateStatus = async (req, res) => {
  const { id } = req.params;
  const { status, tracking_id } = req.body;
  const allowed = ['Processing', 'Shipped', 'Delivered', 'Cancelled'];
  if (!allowed.includes(status)) {
    return res.status(400).json({ success: false, message: 'Invalid status' });
  }

  const result = await pool.query(`
    UPDATE orders SET status = $1::varchar, tracking_id = COALESCE($2, tracking_id),
      payment_status = CASE WHEN $1::varchar = 'Delivered' THEN 'Paid' ELSE payment_status END,
      updated_at = NOW()
    WHERE id = $3 RETURNING *
  `, [status, tracking_id || null, id]);

  if (!result.rows.length) return res.status(404).json({ success: false, message: 'Order not found' });
  res.json({ success: true, data: { order: result.rows[0] } });
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

  res.json({ success: true, message: 'Request updated', data: result.rows[0] });
};

// POST /api/admin/orders/:id/ship — create Delhivery shipment
const adminShipOrder = async (req, res, next) => {
  try {
    const { id } = req.params;

    const result = await pool.query(`
      SELECT o.*, u.name AS customer_name, u.phone AS customer_phone,
             a.name AS addr_name, a.phone AS addr_phone, a.line1 AS address_line1,
             a.line2 AS address_line2, a.city, a.state, a.pincode,
             json_agg(json_build_object('name', p.name, 'quantity', oi.quantity)) AS items
      FROM orders o
      JOIN users u ON u.id = o.user_id
      LEFT JOIN addresses a ON a.id = o.address_id
      LEFT JOIN order_items oi ON oi.order_id = o.id
      LEFT JOIN products p ON p.id = oi.product_id
      WHERE o.id = $1
      GROUP BY o.id, u.name, u.phone, a.name, a.phone, a.line1,
               a.line2, a.city, a.state, a.pincode
    `, [id]);

    if (!result.rows.length) return res.status(404).json({ success: false, message: 'Order not found' });
    const order = result.rows[0];

    if (order.tracking_id) {
      return res.status(400).json({ success: false, message: `Shipment already created. Waybill: ${order.tracking_id}` });
    }

    const orderPayload = {
      ...order,
      address: {
        name: order.addr_name,
        phone: order.addr_phone,
        street: order.address_line1,
        city: order.city,
        state: order.state,
        pincode: order.pincode,
      },
    };

    const waybill = await createShipment(orderPayload);

    await pool.query(
      `UPDATE orders SET tracking_id = $1, status = 'Shipped', updated_at = NOW() WHERE id = $2`,
      [waybill, id]
    );

    res.json({ success: true, message: 'Shipment created on Delhivery', data: { waybill } });
  } catch (err) { next(err); }
};

// GET /api/admin/orders/:id/tracking — live tracking from Delhivery
const adminTrackOrder = async (req, res, next) => {
  try {
    const { id } = req.params;
    const order = await pool.query('SELECT tracking_id FROM orders WHERE id = $1', [id]);
    if (!order.rows.length) return res.status(404).json({ success: false, message: 'Order not found' });

    const waybill = order.rows[0].tracking_id;
    if (!waybill) return res.status(400).json({ success: false, message: 'No waybill assigned to this order yet' });

    const tracking = await trackShipment(waybill);
    res.json({ success: true, data: tracking });
  } catch (err) { next(err); }
};

// GET /api/orders/:id/tracking — customer-facing live tracking
const getOrderTracking = async (req, res, next) => {
  try {
    const { id } = req.params;
    const order = await pool.query(
      'SELECT tracking_id FROM orders WHERE id = $1 AND user_id = $2',
      [id, req.user.id]
    );
    if (!order.rows.length) return res.status(404).json({ success: false, message: 'Order not found' });

    const waybill = order.rows[0].tracking_id;
    if (!waybill) return res.json({ success: true, data: null, message: 'Tracking not available yet' });

    const tracking = await trackShipment(waybill);
    res.json({ success: true, data: tracking });
  } catch (err) { next(err); }
};

module.exports = {
  createOrder, getOrders, getOrder, cancelOrder, requestRefund,
  adminGetOrders, adminUpdateStatus, adminGetRefunds, adminUpdateRefund,
  adminShipOrder, adminTrackOrder, getOrderTracking,
};
