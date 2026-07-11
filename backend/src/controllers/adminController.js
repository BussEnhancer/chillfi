const pool = require('../db/pool');
const { sendPushToTokens } = require('../utils/firebase');

// ── Analytics ──────────────────────────────────────────────────────────────

const getDashboardStats = async (req, res, next) => {
  try {
    const [revenue, orders, products, users, recentOrders, topProducts, monthlyRevenue,
           prevRevenue, prevOrders, prevUsers] = await Promise.all([
      pool.query(`SELECT COALESCE(SUM(total),0) AS total FROM orders WHERE payment_status='Paid'`),
      pool.query(`SELECT COUNT(*) AS total, status FROM orders GROUP BY status`),
      pool.query(`SELECT COUNT(*) AS total FROM products WHERE status!='Inactive'`),
      pool.query(`SELECT COUNT(*) AS total FROM users WHERE role='customer'`),
      // Period comparisons: last 30 days vs prior 30 days
      pool.query(`SELECT COALESCE(SUM(total),0) AS cur,
        (SELECT COALESCE(SUM(total),0) FROM orders WHERE payment_status='Paid'
          AND created_at >= NOW()-INTERVAL '60 days' AND created_at < NOW()-INTERVAL '30 days') AS prev
        FROM orders WHERE payment_status='Paid' AND created_at >= NOW()-INTERVAL '30 days'`),
      pool.query(`SELECT COUNT(*) FILTER (WHERE created_at >= NOW()-INTERVAL '30 days') AS cur,
        COUNT(*) FILTER (WHERE created_at >= NOW()-INTERVAL '60 days' AND created_at < NOW()-INTERVAL '30 days') AS prev
        FROM orders`),
      pool.query(`SELECT COUNT(*) FILTER (WHERE created_at >= NOW()-INTERVAL '30 days') AS cur,
        COUNT(*) FILTER (WHERE created_at >= NOW()-INTERVAL '60 days' AND created_at < NOW()-INTERVAL '30 days') AS prev
        FROM users WHERE role='customer'`),
      pool.query(`
        SELECT o.id, o.order_number, u.name AS customer, o.total, o.status, o.created_at,
               COUNT(oi.id) AS item_count
        FROM orders o
        JOIN users u ON u.id = o.user_id
        JOIN order_items oi ON oi.order_id = o.id
        GROUP BY o.id, u.name
        ORDER BY o.created_at DESC LIMIT 10
      `),
      pool.query(`
        SELECT p.id, p.name, p.price, SUM(oi.quantity) AS units_sold,
               SUM(oi.quantity * oi.price) AS revenue,
               pi.url AS image
        FROM order_items oi
        JOIN products p ON p.id = oi.product_id
        LEFT JOIN LATERAL (SELECT url FROM product_images WHERE product_id=p.id ORDER BY sort_order LIMIT 1) pi ON true
        GROUP BY p.id, p.name, p.price, pi.url
        ORDER BY units_sold DESC LIMIT 5
      `),
      pool.query(`
        SELECT TO_CHAR(created_at,'Mon') AS month,
               EXTRACT(MONTH FROM created_at) AS month_num,
               COALESCE(SUM(total),0) AS revenue
        FROM orders
        WHERE payment_status='Paid'
          AND created_at >= NOW() - INTERVAL '12 months'
        GROUP BY month, month_num
        ORDER BY month_num
      `),
    ]);

    const orderStatusMap = {};
    orders.rows.forEach(r => { orderStatusMap[r.status] = parseInt(r.total); });

    const pctChange = (cur, prev) => {
      const c = parseFloat(cur) || 0;
      const p = parseFloat(prev) || 0;
      if (p === 0) return c > 0 ? 100 : 0;
      return Math.round(((c - p) / p) * 100);
    };

    const revCur = parseFloat(prevRevenue.rows[0].cur);
    const revPrev = parseFloat(prevRevenue.rows[0].prev);
    const ordCur = parseInt(prevOrders.rows[0].cur);
    const ordPrev = parseInt(prevOrders.rows[0].prev);
    const usrCur = parseInt(prevUsers.rows[0].cur);
    const usrPrev = parseInt(prevUsers.rows[0].prev);

    res.json({
      success: true,
      data: {
        revenue: parseFloat(revenue.rows[0].total),
        orders: {
          total: Object.values(orderStatusMap).reduce((a, b) => a + b, 0),
          by_status: orderStatusMap,
        },
        products: parseInt(products.rows[0].total),
        users: parseInt(users.rows[0].total),
        recent_orders: recentOrders.rows,
        top_products: topProducts.rows,
        monthly_revenue: monthlyRevenue.rows,
        changes: {
          revenue: pctChange(revCur, revPrev),
          orders: pctChange(ordCur, ordPrev),
          users: pctChange(usrCur, usrPrev),
        },
      },
    });
  } catch (err) { next(err); }
};

const getAnalytics = async (req, res, next) => {
  try {
    const { period = '30' } = req.query;
    const days = parseInt(period);

    const [sales, topCats, conversionData, userGrowth] = await Promise.all([
      pool.query(`
        SELECT DATE(created_at) AS date, COUNT(*) AS orders, COALESCE(SUM(total),0) AS revenue
        FROM orders
        WHERE created_at >= NOW() - INTERVAL '${days} days'
        GROUP BY DATE(created_at)
        ORDER BY date
      `),
      pool.query(`
        SELECT c.name AS category, COUNT(oi.id) AS items_sold, SUM(oi.quantity*oi.price) AS revenue
        FROM order_items oi
        JOIN products p ON p.id=oi.product_id
        JOIN categories c ON c.id=p.category_id
        JOIN orders o ON o.id = oi.order_id
        WHERE o.created_at >= NOW() - INTERVAL '${days} days'
        GROUP BY c.name ORDER BY revenue DESC LIMIT 6
      `),
      pool.query(`
        SELECT COUNT(DISTINCT user_id) AS buyers FROM orders
        WHERE created_at >= NOW() - INTERVAL '${days} days'
      `),
      pool.query(`
        SELECT DATE(created_at) AS date, COUNT(*) AS new_users
        FROM users WHERE role='customer'
          AND created_at >= NOW() - INTERVAL '${days} days'
        GROUP BY DATE(created_at) ORDER BY date
      `),
    ]);

    res.json({
      success: true,
      data: {
        sales_over_time: sales.rows,
        top_categories: topCats.rows,
        unique_buyers: parseInt(conversionData.rows[0]?.buyers || 0),
        user_growth: userGrowth.rows,
      },
    });
  } catch (err) { next(err); }
};

// ── Users ──────────────────────────────────────────────────────────────────

const getUsers = async (req, res, next) => {
  try {
    const { page = 1, limit = 20, search = '', status = '' } = req.query;
    const offset = (page - 1) * limit;

    const where = [];
    const params = [];

    if (search) {
      params.push(`%${search}%`);
      where.push(`(u.name ILIKE $${params.length} OR u.email ILIKE $${params.length} OR u.phone ILIKE $${params.length})`);
    }
    if (status) {
      params.push(status === 'Active');
      where.push(`u.is_active = $${params.length}`);
    }

    const whereClause = where.length ? `WHERE ${where.join(' AND ')}` : '';

    const [rows, count] = await Promise.all([
      pool.query(`
        SELECT u.id, u.name, u.email, u.phone, u.role,
               CASE WHEN u.is_active THEN 'Active' ELSE 'Blocked' END AS status,
               u.created_at,
               COUNT(o.id) AS total_orders,
               COALESCE(SUM(o.total),0) AS total_spent
        FROM users u
        LEFT JOIN orders o ON o.user_id=u.id AND o.payment_status='Paid'
        ${whereClause}
        GROUP BY u.id ORDER BY u.created_at DESC
        LIMIT $${params.length+1} OFFSET $${params.length+2}
      `, [...params, limit, offset]),
      pool.query(`SELECT COUNT(*) FROM users u ${whereClause}`, params),
    ]);

    res.json({ success: true, data: { users: rows.rows, total: parseInt(count.rows[0].count) } });
  } catch (err) { next(err); }
};

const updateUserStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { status } = req.body;
    await pool.query('UPDATE users SET is_active=$1 WHERE id=$2', [status === 'Active', id]);
    res.json({ success: true, message: `User ${status.toLowerCase()}` });
  } catch (err) { next(err); }
};

const updateUserRole = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { role } = req.body;
    if (!['customer', 'admin', 'support_staff'].includes(role)) {
      return res.status(400).json({ success: false, message: 'Invalid role' });
    }
    const result = await pool.query('UPDATE users SET role=$1 WHERE id=$2 RETURNING id, name, email, phone, role', [role, id]);
    if (!result.rows.length) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, message: 'Role updated', data: result.rows[0] });
  } catch (err) { next(err); }
};

// ── Banners ────────────────────────────────────────────────────────────────

const getBanners = async (req, res, next) => {
  try {
    const result = await pool.query('SELECT * FROM banners ORDER BY sort_order');
    res.json({ success: true, data: result.rows });
  } catch (err) { next(err); }
};

// ── Shipping Rules ───────────────────────────────────────────────────────────

const getShippingRules = async (req, res, next) => {
  try {
    const result = await pool.query('SELECT * FROM shipping_rules ORDER BY pincode_prefix');
    res.json({ success: true, data: result.rows });
  } catch (err) { next(err); }
};

const createShippingRule = async (req, res, next) => {
  try {
    const { pincode_prefix, fee, free_above, cod_available = true, estimated_days = 5, is_active = true } = req.body;
    if (!pincode_prefix || fee === undefined) {
      return res.status(400).json({ success: false, message: 'pincode_prefix and fee are required' });
    }
    const result = await pool.query(
      `INSERT INTO shipping_rules (pincode_prefix, fee, free_above, cod_available, estimated_days, is_active)
       VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
      [pincode_prefix, fee, free_above ?? null, cod_available, estimated_days, is_active]
    );
    res.status(201).json({ success: true, message: 'Shipping rule created', data: result.rows[0] });
  } catch (err) { next(err); }
};

const updateShippingRule = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { pincode_prefix, fee, free_above, cod_available, estimated_days, is_active } = req.body;
    const result = await pool.query(
      `UPDATE shipping_rules SET pincode_prefix=COALESCE($1,pincode_prefix), fee=COALESCE($2,fee),
       free_above=COALESCE($3,free_above), cod_available=COALESCE($4,cod_available),
       estimated_days=COALESCE($5,estimated_days), is_active=COALESCE($6,is_active)
       WHERE id=$7 RETURNING *`,
      [pincode_prefix, fee, free_above ?? null, cod_available, estimated_days, is_active, id]
    );
    if (!result.rows.length) return res.status(404).json({ success: false, message: 'Rule not found' });
    res.json({ success: true, message: 'Shipping rule updated', data: result.rows[0] });
  } catch (err) { next(err); }
};

const deleteShippingRule = async (req, res, next) => {
  try {
    await pool.query('DELETE FROM shipping_rules WHERE id=$1', [req.params.id]);
    res.json({ success: true, message: 'Shipping rule deleted' });
  } catch (err) { next(err); }
};

const createBanner = async (req, res, next) => {
  try {
    const { title, subtitle, image_url, link, sort_order = 0, is_active = true } = req.body;
    const result = await pool.query(
      `INSERT INTO banners (title, subtitle, image_url, link, sort_order, is_active)
       VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
      [title, subtitle, image_url, link, sort_order, is_active]
    );
    res.json({ success: true, message: 'Banner created', data: result.rows[0] });
  } catch (err) { next(err); }
};

const updateBanner = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { title, subtitle, image_url, link, sort_order, is_active } = req.body;
    const result = await pool.query(
      `UPDATE banners SET title=COALESCE($1,title), subtitle=COALESCE($2,subtitle),
       image_url=COALESCE($3,image_url), link=COALESCE($4,link),
       sort_order=COALESCE($5,sort_order),
       is_active=COALESCE($6,is_active) WHERE id=$7 RETURNING *`,
      [title, subtitle, image_url, link, sort_order, is_active, id]
    );
    res.json({ success: true, message: 'Banner updated', data: result.rows[0] });
  } catch (err) { next(err); }
};

const deleteBanner = async (req, res, next) => {
  try {
    await pool.query('DELETE FROM banners WHERE id=$1', [req.params.id]);
    res.json({ success: true, message: 'Banner deleted' });
  } catch (err) { next(err); }
};

// ── Testimonials ─────────────────────────────────────────────────────────────

const getTestimonials = async (req, res, next) => {
  try {
    const result = await pool.query('SELECT * FROM testimonials ORDER BY sort_order');
    res.json({ success: true, data: result.rows });
  } catch (err) { next(err); }
};

const createTestimonial = async (req, res, next) => {
  try {
    const { customer_name, avatar_url, rating, quote, sort_order = 0, is_active = true } = req.body;
    const result = await pool.query(
      `INSERT INTO testimonials (customer_name, avatar_url, rating, quote, sort_order, is_active)
       VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
      [customer_name, avatar_url, rating, quote, sort_order, is_active]
    );
    res.json({ success: true, message: 'Testimonial created', data: result.rows[0] });
  } catch (err) { next(err); }
};

const updateTestimonial = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { customer_name, avatar_url, rating, quote, sort_order, is_active } = req.body;
    const result = await pool.query(
      `UPDATE testimonials SET customer_name=COALESCE($1,customer_name), avatar_url=COALESCE($2,avatar_url),
       rating=COALESCE($3,rating), quote=COALESCE($4,quote), sort_order=COALESCE($5,sort_order),
       is_active=COALESCE($6,is_active) WHERE id=$7 RETURNING *`,
      [customer_name, avatar_url, rating, quote, sort_order, is_active, id]
    );
    res.json({ success: true, message: 'Testimonial updated', data: result.rows[0] });
  } catch (err) { next(err); }
};

const deleteTestimonial = async (req, res, next) => {
  try {
    await pool.query('DELETE FROM testimonials WHERE id=$1', [req.params.id]);
    res.json({ success: true, message: 'Testimonial deleted' });
  } catch (err) { next(err); }
};

// ── Promo Banners ─────────────────────────────────────────────────────────────

const getPromoBanners = async (req, res, next) => {
  try {
    const result = await pool.query('SELECT * FROM promo_banners ORDER BY sort_order');
    res.json({ success: true, data: result.rows });
  } catch (err) { next(err); }
};

const createPromoBanner = async (req, res, next) => {
  try {
    const { title, subtitle, image_url, link, background_color, sort_order = 0, is_active = true } = req.body;
    const result = await pool.query(
      `INSERT INTO promo_banners (title, subtitle, image_url, link, background_color, sort_order, is_active)
       VALUES ($1,$2,$3,$4,$5,$6,$7) RETURNING *`,
      [title, subtitle, image_url, link, background_color, sort_order, is_active]
    );
    res.json({ success: true, message: 'Promo banner created', data: result.rows[0] });
  } catch (err) { next(err); }
};

const updatePromoBanner = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { title, subtitle, image_url, link, background_color, sort_order, is_active } = req.body;
    const result = await pool.query(
      `UPDATE promo_banners SET title=COALESCE($1,title), subtitle=COALESCE($2,subtitle),
       image_url=COALESCE($3,image_url), link=COALESCE($4,link),
       background_color=COALESCE($5,background_color), sort_order=COALESCE($6,sort_order),
       is_active=COALESCE($7,is_active) WHERE id=$8 RETURNING *`,
      [title, subtitle, image_url, link, background_color, sort_order, is_active, id]
    );
    res.json({ success: true, message: 'Promo banner updated', data: result.rows[0] });
  } catch (err) { next(err); }
};

const deletePromoBanner = async (req, res, next) => {
  try {
    await pool.query('DELETE FROM promo_banners WHERE id=$1', [req.params.id]);
    res.json({ success: true, message: 'Promo banner deleted' });
  } catch (err) { next(err); }
};

// ── Coupons ────────────────────────────────────────────────────────────────

const getCoupons = async (req, res, next) => {
  try {
    const result = await pool.query(`
      SELECT c.*, COUNT(cu.id) AS used_count
      FROM coupons c
      LEFT JOIN coupon_usage cu ON cu.coupon_id=c.id
      GROUP BY c.id ORDER BY c.created_at DESC
    `);
    res.json({ success: true, data: result.rows });
  } catch (err) { next(err); }
};

const createCoupon = async (req, res, next) => {
  try {
    const { code, type, value, min_order = 0, max_discount = 0, total_uses, usage_limit, expires_at, is_active = true } = req.body;
    const existing = await pool.query('SELECT id FROM coupons WHERE code=$1', [code.toUpperCase()]);
    if (existing.rows.length) return res.status(400).json({ success: false, message: 'Coupon code already exists' });

    const usageLimit = usage_limit || total_uses || null;
    const result = await pool.query(
      `INSERT INTO coupons (code, type, value, min_order, max_discount, usage_limit, expires_at, is_active)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *`,
      [code.toUpperCase(), type, value, min_order, max_discount, usageLimit, expires_at || null, is_active]
    );
    res.json({ success: true, message: 'Coupon created', data: result.rows[0] });
  } catch (err) { next(err); }
};

const updateCoupon = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { code, type, value, min_order, max_discount, total_uses, usage_limit, expires_at, is_active } = req.body;
    const usageLimit = usage_limit ?? total_uses ?? undefined;
    const result = await pool.query(
      `UPDATE coupons SET code=COALESCE($1,code), type=COALESCE($2,type), value=COALESCE($3,value),
       min_order=COALESCE($4,min_order), max_discount=COALESCE($5,max_discount),
       usage_limit=COALESCE($6,usage_limit), expires_at=COALESCE($7,expires_at),
       is_active=COALESCE($8,is_active) WHERE id=$9 RETURNING *`,
      [code, type, value, min_order, max_discount, usageLimit, expires_at, is_active, id]
    );
    res.json({ success: true, message: 'Coupon updated', data: result.rows[0] });
  } catch (err) { next(err); }
};

const deleteCoupon = async (req, res, next) => {
  try {
    await pool.query('DELETE FROM coupons WHERE id=$1', [req.params.id]);
    res.json({ success: true, message: 'Coupon deleted' });
  } catch (err) { next(err); }
};

// ── Reviews ────────────────────────────────────────────────────────────────

const getReviews = async (req, res, next) => {
  try {
    const { page = 1, limit = 20, rating, product_id } = req.query;
    const offset = (page - 1) * limit;
    const values = [];
    const conditions = [];

    if (rating) { values.push(rating); conditions.push(`r.rating = $${values.length}`); }
    if (product_id) { values.push(product_id); conditions.push(`r.product_id = $${values.length}`); }
    const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';

    const [rows, count] = await Promise.all([
      pool.query(`
        SELECT r.id, r.rating, r.title, r.body, r.is_verified, r.created_at,
               u.id AS user_id, u.name AS user_name,
               p.id AS product_id, p.name AS product_name
        FROM reviews r
        JOIN users u ON u.id = r.user_id
        JOIN products p ON p.id = r.product_id
        ${where}
        ORDER BY r.created_at DESC
        LIMIT $${values.length + 1} OFFSET $${values.length + 2}
      `, [...values, limit, offset]),
      pool.query(`SELECT COUNT(*) FROM reviews r ${where}`, values),
    ]);

    res.json({ success: true, data: { reviews: rows.rows, total: parseInt(count.rows[0].count) } });
  } catch (err) { next(err); }
};

const deleteReview = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await pool.query('SELECT product_id FROM reviews WHERE id=$1', [id]);
    if (!result.rows.length) return res.status(404).json({ success: false, message: 'Review not found' });
    const { product_id } = result.rows[0];

    await pool.query('DELETE FROM reviews WHERE id=$1', [id]);
    await pool.query(`
      UPDATE products SET
        rating = COALESCE((SELECT ROUND(AVG(rating), 1) FROM reviews WHERE product_id = $1), 0),
        review_count = (SELECT COUNT(*) FROM reviews WHERE product_id = $1)
      WHERE id = $1
    `, [product_id]);

    res.json({ success: true, message: 'Review deleted' });
  } catch (err) { next(err); }
};

// ── Contact Messages ─────────────────────────────────────────────────────────

const getMessages = async (req, res, next) => {
  try {
    const { page = 1, limit = 20, is_read } = req.query;
    const offset = (page - 1) * limit;
    const values = [];
    let where = '';
    if (is_read !== undefined) { values.push(is_read === 'true'); where = `WHERE is_read = $${values.length}`; }

    const [rows, count] = await Promise.all([
      pool.query(`
        SELECT * FROM contact_messages ${where}
        ORDER BY created_at DESC
        LIMIT $${values.length + 1} OFFSET $${values.length + 2}
      `, [...values, limit, offset]),
      pool.query(`SELECT COUNT(*) FROM contact_messages ${where}`, values),
    ]);

    res.json({ success: true, data: { messages: rows.rows, total: parseInt(count.rows[0].count) } });
  } catch (err) { next(err); }
};

const updateMessageReadStatus = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { is_read } = req.body;
    const result = await pool.query('UPDATE contact_messages SET is_read=$1 WHERE id=$2 RETURNING *', [!!is_read, id]);
    if (!result.rows.length) return res.status(404).json({ success: false, message: 'Message not found' });
    res.json({ success: true, data: result.rows[0] });
  } catch (err) { next(err); }
};

const replyToMessage = async (req, res, next) => {
  try {
    const { id } = req.params;
    const { reply } = req.body;
    if (!reply || !reply.trim()) return res.status(400).json({ success: false, message: 'Reply text is required' });

    const result = await pool.query(
      `UPDATE contact_messages SET reply=$1, replied_at=NOW(), replied_by=$2, is_read=TRUE
       WHERE id=$3 RETURNING *`,
      [reply.trim(), req.user.id, id]
    );
    if (!result.rows.length) return res.status(404).json({ success: false, message: 'Message not found' });
    res.json({ success: true, message: 'Reply saved', data: result.rows[0] });
  } catch (err) { next(err); }
};

const deleteMessage = async (req, res, next) => {
  try {
    await pool.query('DELETE FROM contact_messages WHERE id=$1', [req.params.id]);
    res.json({ success: true, message: 'Message deleted' });
  } catch (err) { next(err); }
};

// ── Store Settings ─────────────────────────────────────────────────────────

const getSettings = async (req, res, next) => {
  try {
    const result = await pool.query('SELECT key, value FROM store_settings');
    const data = {};
    result.rows.forEach(row => { data[row.key] = row.value; });
    res.json({ success: true, data });
  } catch (err) { next(err); }
};

const updateSettings = async (req, res, next) => {
  try {
    const fields = req.body;
    const keys = Object.keys(fields);
    if (!keys.length) return res.status(400).json({ success: false, message: 'No fields to update' });

    for (const key of keys) {
      const value = fields[key] === null || fields[key] === undefined ? null : String(fields[key]);
      await pool.query(
        `INSERT INTO store_settings (key, value) VALUES ($1, $2)
         ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW()`,
        [key, value]
      );
    }

    const result = await pool.query('SELECT key, value FROM store_settings');
    const data = {};
    result.rows.forEach(row => { data[row.key] = row.value; });
    res.json({ success: true, message: 'Settings updated', data });
  } catch (err) { next(err); }
};

// ── API Credentials ────────────────────────────────────────────────────────

const CREDENTIAL_KEYS = [
  { key: 'OTP_PROVIDER', label: 'OTP Provider', group: 'otp', secret: false, options: ['2factor', 'msg91'] },
  { key: 'TWO_FACTOR_API_KEY', label: '2Factor.in API Key', group: 'otp', secret: true },
  { key: 'MSG91_AUTH_KEY', label: 'MSG91 Auth Key', group: 'otp', secret: true },
  { key: 'MSG91_TEMPLATE_ID', label: 'MSG91 Template ID', group: 'otp', secret: false },
  { key: 'MSG91_SENDER_ID', label: 'MSG91 Sender ID', group: 'otp', secret: false },
  { key: 'FIREBASE_SERVER_KEY', label: 'Firebase Server Key', group: 'firebase', secret: true },
  { key: 'PHONEPE_MERCHANT_ID', label: 'PhonePe Merchant ID', group: 'payment', secret: false },
  { key: 'PHONEPE_SALT_KEY', label: 'PhonePe Salt Key', group: 'payment', secret: true },
  { key: 'PHONEPE_SALT_INDEX', label: 'PhonePe Salt Index', group: 'payment', secret: false },
  { key: 'RAZORPAY_KEY_ID', label: 'Razorpay Key ID', group: 'payment', secret: false },
  { key: 'RAZORPAY_KEY_SECRET', label: 'Razorpay Key Secret', group: 'payment', secret: true },
  { key: 'CLOUDINARY_CLOUD_NAME', label: 'Cloudinary Cloud Name', group: 'media', secret: false },
  { key: 'CLOUDINARY_API_KEY', label: 'Cloudinary API Key', group: 'media', secret: false },
  { key: 'CLOUDINARY_API_SECRET', label: 'Cloudinary API Secret', group: 'media', secret: true },
  { key: 'DELHIVERY_TOKEN', label: 'Delhivery API Token', group: 'shipping', secret: true },
  { key: 'DELHIVERY_CLIENT_NAME', label: 'Delhivery Client Name', group: 'shipping', secret: false },
  { key: 'DELHIVERY_PICKUP_LOCATION', label: 'Delhivery Pickup Location Name', group: 'shipping', secret: false },
];

const { invalidateCache } = require('../utils/settings');

const getCredentials = async (req, res, next) => {
  try {
    const result = await pool.query('SELECT key, value FROM store_settings');
    const dbVals = {};
    result.rows.forEach(r => { dbVals[r.key] = r.value; });

    const data = CREDENTIAL_KEYS.map(meta => {
      const rawVal = dbVals[meta.key] || process.env[meta.key] || '';
      const maskedVal = meta.secret && rawVal.length > 6
        ? rawVal.slice(0, 4) + '••••' + rawVal.slice(-4)
        : rawVal;
      return { ...meta, value: maskedVal, isSet: !!rawVal };
    });

    res.json({ success: true, data });
  } catch (err) { next(err); }
};

const updateCredentials = async (req, res, next) => {
  try {
    const { key, value } = req.body;
    if (!key) return res.status(400).json({ success: false, message: 'key required' });

    const meta = CREDENTIAL_KEYS.find(c => c.key === key);
    if (!meta) return res.status(400).json({ success: false, message: 'Unknown credential key' });

    await pool.query(
      `INSERT INTO store_settings (key, value) VALUES ($1, $2)
       ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW()`,
      [key, value || null]
    );
    invalidateCache(key);

    res.json({ success: true, message: `${meta.label} updated` });
  } catch (err) { next(err); }
};

// ── Image Upload ───────────────────────────────────────────────────────────

const { uploadToCloudinary } = require('../middleware/upload');

const uploadImage = async (req, res, next) => {
  try {
    if (!req.file) return res.status(400).json({ success: false, message: 'No file uploaded' });
    const folder = req.body.folder || 'chillfi/general';
    const result = await uploadToCloudinary(req.file.buffer, folder);
    res.json({ success: true, data: { url: result.secure_url, public_id: result.public_id } });
  } catch (err) { next(err); }
};

const deleteImage = async (req, res, next) => {
  try {
    const { public_id } = req.body;
    if (!public_id) return res.status(400).json({ success: false, message: 'public_id required' });
    const { cloudinary } = require('../middleware/upload');
    await cloudinary.uploader.destroy(public_id);
    res.json({ success: true, message: 'Image deleted' });
  } catch (err) { next(err); }
};

// ── Send Push Notification ─────────────────────────────────────────────────

const sendPushNotification = async (req, res, next) => {
  try {
    const { title, body, user_id } = req.body;
    if (!title || !body) return res.status(400).json({ success: false, message: 'title and body required' });

    // Save to notifications table
    if (user_id) {
      await pool.query(
        'INSERT INTO notifications (user_id, title, body, type) VALUES ($1,$2,$3,$4)',
        [user_id, title, body, 'admin']
      );
    } else {
      // Broadcast: insert for all customers
      await pool.query(
        `INSERT INTO notifications (user_id, title, body, type)
         SELECT id, $1, $2, 'broadcast' FROM users WHERE role='customer'`,
        [title, body]
      );
    }

    // Fetch device tokens for the target audience and deliver via FCM
    const tokenResult = user_id
      ? await pool.query('SELECT token FROM fcm_tokens WHERE user_id = $1', [user_id])
      : await pool.query(
          `SELECT ft.token FROM fcm_tokens ft JOIN users u ON u.id = ft.user_id WHERE u.role = 'customer'`
        );
    const tokens = tokenResult.rows.map((r) => r.token);

    const { successCount, failureCount, invalidTokens } = await sendPushToTokens(tokens, { title, body });

    if (invalidTokens.length) {
      await pool.query('DELETE FROM fcm_tokens WHERE token = ANY($1::text[])', [invalidTokens]);
    }

    res.json({
      success: true,
      message: user_id ? 'Notification sent to user' : 'Broadcast sent to all customers',
      data: { devicesTargeted: tokens.length, delivered: successCount, failed: failureCount },
    });
  } catch (err) { next(err); }
};

module.exports = {
  getDashboardStats, getAnalytics,
  getUsers, updateUserStatus, updateUserRole,
  getBanners, createBanner, updateBanner, deleteBanner,
  getShippingRules, createShippingRule, updateShippingRule, deleteShippingRule,
  getTestimonials, createTestimonial, updateTestimonial, deleteTestimonial,
  getPromoBanners, createPromoBanner, updatePromoBanner, deletePromoBanner,
  getCoupons, createCoupon, updateCoupon, deleteCoupon,
  getReviews, deleteReview,
  getMessages, updateMessageReadStatus, replyToMessage, deleteMessage,
  getSettings, updateSettings,
  getCredentials, updateCredentials,
  uploadImage, deleteImage,
  sendPushNotification,
};
