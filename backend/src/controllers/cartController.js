const pool = require('../db/pool');
const { getShippingFee } = require('../utils/shipping');
const { getGstAmount } = require('../utils/tax');

const getOrCreateCart = async (userId) => {
  let result = await pool.query('SELECT id FROM cart WHERE user_id = $1', [userId]);
  if (!result.rows.length) {
    result = await pool.query('INSERT INTO cart (user_id) VALUES ($1) RETURNING id', [userId]);
  }
  return result.rows[0].id;
};

// GET /api/cart
const getCart = async (req, res) => {
  const cartId = await getOrCreateCart(req.user.id);
  const items = await pool.query(`
    SELECT ci.id, ci.quantity, ci.product_id,
      p.name, p.price, p.old_price, p.stock, p.status,
      b.name as brand_name,
      (SELECT url FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as image
    FROM cart_items ci
    JOIN products p ON ci.product_id = p.id
    LEFT JOIN brands b ON p.brand_id = b.id
    WHERE ci.cart_id = $1
    ORDER BY ci.added_at DESC
  `, [cartId]);

  const subtotal = items.rows.reduce((s, i) => s + i.price * i.quantity, 0);
  const savings = items.rows.reduce((s, i) => s + (i.old_price ? (i.old_price - i.price) * i.quantity : 0), 0);
  const deliveryFee = items.rows.length ? await getShippingFee(req.query.pincode, subtotal) : 0;
  const taxAmount = items.rows.length ? await getGstAmount(subtotal) : 0;

  res.json({
    success: true,
    data: {
      items: items.rows,
      summary: {
        item_count: items.rows.reduce((s, i) => s + i.quantity, 0),
        subtotal: parseFloat(subtotal.toFixed(2)),
        savings: parseFloat(savings.toFixed(2)),
        delivery_fee: deliveryFee,
        tax_amount: taxAmount,
        total: parseFloat((subtotal + deliveryFee + taxAmount).toFixed(2)),
      },
    },
  });
};

// POST /api/cart/add
const addToCart = async (req, res) => {
  const { product_id } = req.body;
  const quantity = Number(req.body.quantity ?? 1);
  if (!product_id) return res.status(400).json({ success: false, message: 'Product ID required' });
  if (!Number.isInteger(quantity) || quantity < 1) return res.status(400).json({ success: false, message: 'Quantity must be at least 1' });

  const product = await pool.query('SELECT id, stock, status FROM products WHERE id = $1', [product_id]);
  if (!product.rows.length) return res.status(404).json({ success: false, message: 'Product not found' });
  if (product.rows[0].status === 'Inactive') {
    return res.status(400).json({ success: false, message: 'This product is no longer available.' });
  }
  if (product.rows[0].status === 'Out of Stock' || product.rows[0].stock < 1) {
    return res.status(400).json({ success: false, message: 'Product out of stock' });
  }

  const cartId = await getOrCreateCart(req.user.id);
  const existing = await pool.query('SELECT quantity FROM cart_items WHERE cart_id = $1 AND product_id = $2', [cartId, product_id]);
  const wanted = (existing.rows[0]?.quantity || 0) + quantity;
  if (wanted > product.rows[0].stock) {
    return res.status(400).json({ success: false, message: `Only ${product.rows[0].stock} left in stock` });
  }
  await pool.query(`
    INSERT INTO cart_items (cart_id, product_id, quantity)
    VALUES ($1, $2, $3)
    ON CONFLICT (cart_id, product_id) DO UPDATE SET quantity = cart_items.quantity + $3
  `, [cartId, product_id, quantity]);

  res.json({ success: true, message: 'Added to cart' });
};

// PUT /api/cart/item/:id
const updateCartItem = async (req, res) => {
  const { id } = req.params;
  const quantity = Number(req.body.quantity);
  if (!Number.isInteger(quantity) || quantity < 1) {
    return res.status(400).json({ success: false, message: 'Quantity must be at least 1' });
  }

  const cartId = await getOrCreateCart(req.user.id);
  const stock = await pool.query(
    'SELECT p.stock FROM cart_items ci JOIN products p ON p.id = ci.product_id WHERE ci.id = $1 AND ci.cart_id = $2', [id, cartId]);
  if (stock.rows.length && quantity > stock.rows[0].stock) {
    return res.status(400).json({ success: false, message: `Only ${stock.rows[0].stock} left in stock` });
  }
  await pool.query(
    'UPDATE cart_items SET quantity = $1 WHERE id = $2 AND cart_id = $3',
    [quantity, id, cartId]
  );
  res.json({ success: true, message: 'Cart updated' });
};

// DELETE /api/cart/item/:id
const removeCartItem = async (req, res) => {
  const { id } = req.params;
  const cartId = await getOrCreateCart(req.user.id);
  await pool.query('DELETE FROM cart_items WHERE id = $1 AND cart_id = $2', [id, cartId]);
  res.json({ success: true, message: 'Item removed' });
};

// DELETE /api/cart/clear
const clearCart = async (req, res) => {
  const cartId = await getOrCreateCart(req.user.id);
  await pool.query('DELETE FROM cart_items WHERE cart_id = $1', [cartId]);
  res.json({ success: true, message: 'Cart cleared' });
};

// POST /api/cart/apply-coupon
const applyCoupon = async (req, res) => {
  const { code, order_total } = req.body;
  if (!code) return res.status(400).json({ success: false, message: 'Coupon code required' });

  const result = await pool.query(`
    SELECT * FROM coupons
    WHERE UPPER(code) = UPPER($1) AND is_active = TRUE
      AND (expires_at IS NULL OR expires_at > NOW())
      AND (usage_limit IS NULL OR used_count < usage_limit)
  `, [code]);

  if (!result.rows.length) {
    return res.status(400).json({ success: false, message: 'Invalid or expired coupon' });
  }

  const coupon = result.rows[0];

  // Always compute total from the DB cart — never trust client-provided order_total
  const cartRows = await pool.query(
    `SELECT ci.quantity, p.price FROM cart_items ci
     JOIN cart c ON ci.cart_id = c.id
     JOIN products p ON ci.product_id = p.id
     WHERE c.user_id = $1`,
    [req.user.id]
  );
  const cartSubtotal = cartRows.rows.reduce((s, r) => s + parseFloat(r.price) * r.quantity, 0);
  const total = cartSubtotal; // server-side cart value only (client order_total is ignored)

  if (total < coupon.min_order) {
    return res.status(400).json({
      success: false,
      message: `Add items worth ₹${Math.round(Number(coupon.min_order)).toLocaleString("en-IN")} or more to use this coupon`,
    });
  }

  // Check if user already used this coupon
  const used = await pool.query(
    'SELECT id FROM coupon_usage WHERE coupon_id = $1 AND user_id = $2',
    [coupon.id, req.user.id]
  );
  if (used.rows.length) {
    return res.status(400).json({ success: false, message: 'You have already used this coupon' });
  }

  const couponValue = parseFloat(coupon.value) || 0;
  const maxDiscount = parseFloat(coupon.max_discount) || 0;
  let discount = 0;
  if (coupon.type === 'Percentage') {
    discount = (total * couponValue) / 100;
    if (maxDiscount > 0) discount = Math.min(discount, maxDiscount);
  } else if (coupon.type === 'Flat') {
    discount = couponValue;
  } else if (coupon.type === 'Free Shipping') {
    discount = 49;
  }

  discount = parseFloat(discount.toFixed(2));

  res.json({
    success: true,
    message: 'Coupon applied!',
    data: {
      coupon_id: coupon.id,
      code: coupon.code,
      type: coupon.type,
      discount,
      final_total: parseFloat((total - discount).toFixed(2)),
    },
  });
};

// GET /api/coupons  (public active coupons)
const getActiveCoupons = async (req, res) => {
  const result = await pool.query(`
    SELECT id, code, type, value, min_order, max_discount, expires_at
    FROM coupons
    WHERE is_active = TRUE AND (expires_at IS NULL OR expires_at > NOW()) AND (usage_limit IS NULL OR used_count < usage_limit)
    ORDER BY created_at DESC
  `);
  res.json({ success: true, data: { coupons: result.rows } });
};

module.exports = { getCart, addToCart, updateCartItem, removeCartItem, clearCart, applyCoupon, getActiveCoupons };
