const pool = require('../db/pool');
const { sendPushToTokens } = require('../utils/firebase');

// ── Analytics ──────────────────────────────────────────────────────────────

// Single definition of revenue used by Dashboard and Analytics: money actually received and kept
// (paid online or COD collected) — excluding orders that were cancelled (refund due) or refunded.
const PAID_KEPT = `payment_status='Paid' AND status <> 'Cancelled'`;

const getDashboardStats = async (req, res, next) => {
  try {
    const [revenue, orders, products, users, prevRevenue, prevOrders, prevUsers,
           recentOrders, topProducts, monthlyRevenue] = await Promise.all([
      pool.query(`SELECT COALESCE(SUM(total),0) AS total FROM orders WHERE ${PAID_KEPT}`),
      pool.query(`SELECT COUNT(*) AS total, status FROM orders GROUP BY status`),
      pool.query(`SELECT COUNT(*) AS total FROM products WHERE status!='Inactive'`),
      pool.query(`SELECT COUNT(*) AS total FROM users WHERE role='customer'`),
      // Period comparisons: last 30 days vs prior 30 days
      pool.query(`SELECT COALESCE(SUM(total),0) AS cur,
        (SELECT COALESCE(SUM(total),0) FROM orders WHERE ${PAID_KEPT}
          AND created_at >= NOW()-INTERVAL '60 days' AND created_at < NOW()-INTERVAL '30 days') AS prev
        FROM orders WHERE ${PAID_KEPT} AND created_at >= NOW()-INTERVAL '30 days'`),
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
        JOIN orders o ON o.id = oi.order_id AND o.status <> 'Cancelled'
        JOIN products p ON p.id = oi.product_id
        LEFT JOIN LATERAL (SELECT url FROM product_images WHERE product_id=p.id ORDER BY sort_order LIMIT 1) pi ON true
        GROUP BY p.id, p.name, p.price, pi.url
        ORDER BY units_sold DESC LIMIT 5
      `),
      pool.query(`
        SELECT TO_CHAR(DATE_TRUNC('month', created_at),'Mon') AS month,
               EXTRACT(MONTH FROM DATE_TRUNC('month', created_at)) AS month_num,
               COALESCE(SUM(total),0) AS revenue
        FROM orders
        WHERE ${PAID_KEPT}
          AND created_at >= NOW() - INTERVAL '12 months'
        GROUP BY DATE_TRUNC('month', created_at)
        ORDER BY DATE_TRUNC('month', created_at)
      `),
    ]);

    const orderStatusMap = {};
    orders.rows.forEach(r => { orderStatusMap[r.status] = parseInt(r.total); });

    const pctChange = (cur, prev) => {
      const c = parseFloat(cur) || 0;
      const p = parseFloat(prev) || 0;
      if (p === 0) return null; // no previous-period data → no % (UI shows nothing / "New")
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
    const days = Math.max(1, Math.min(365, parseInt(period) || 30));

    const [sales, topCats, conversionData, userGrowth, regions] = await Promise.all([
      pool.query(`
        SELECT DATE(created_at) AS date, COUNT(*) AS orders,
               COALESCE(SUM(total) FILTER (WHERE ${PAID_KEPT}),0) AS revenue
        FROM orders
        WHERE created_at >= NOW() - ($1 * INTERVAL '1 day')
        GROUP BY DATE(created_at)
        ORDER BY date
      `, [days]),
      pool.query(`
        SELECT c.name AS category, COUNT(oi.id) AS items_sold, SUM(oi.quantity*oi.price) AS revenue
        FROM order_items oi
        JOIN products p ON p.id=oi.product_id
        JOIN categories c ON c.id=p.category_id
        JOIN orders o ON o.id = oi.order_id
        WHERE o.created_at >= NOW() - ($1 * INTERVAL '1 day') AND o.status <> 'Cancelled'
        GROUP BY c.name ORDER BY revenue DESC LIMIT 6
      `, [days]),
      pool.query(`
        SELECT COUNT(DISTINCT user_id) AS buyers FROM orders
        WHERE created_at >= NOW() - ($1 * INTERVAL '1 day')
      `, [days]),
      pool.query(`
        SELECT DATE(created_at) AS date, COUNT(*) AS new_users
        FROM users WHERE role='customer'
          AND created_at >= NOW() - ($1 * INTERVAL '1 day')
        GROUP BY DATE(created_at) ORDER BY date
      `, [days]),
      pool.query(`
        SELECT COALESCE(NULLIF(TRIM(COALESCE(o.shipping_address->>'state', a.state)), ''), 'Unknown') AS region, COUNT(*) AS orders,
               COALESCE(SUM(o.total) FILTER (WHERE o.payment_status='Paid' AND o.status <> 'Cancelled'),0) AS revenue
        FROM orders o LEFT JOIN addresses a ON a.id = o.address_id
        WHERE o.created_at >= NOW() - ($1 * INTERVAL '1 day') AND o.status <> 'Cancelled'
        GROUP BY 1 ORDER BY revenue DESC, orders DESC LIMIT 6
      `, [days]),
    ]);

    res.json({
      success: true,
      data: {
        sales_over_time: sales.rows,
        top_categories: topCats.rows,
        unique_buyers: parseInt(conversionData.rows[0]?.buyers || 0),
        user_growth: userGrowth.rows,
        top_regions: regions.rows,
      },
    });
  } catch (err) { next(err); }
};

// ── Users ──────────────────────────────────────────────────────────────────

const getUsers = async (req, res, next) => {
  try {
    const { search = '', status = '' } = req.query;
    const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 20, 1), 200);
    const page = Math.max(parseInt(req.query.page, 10) || 1, 1);
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
               COALESCE(SUM(CASE WHEN o.payment_status='Paid' THEN o.total ELSE 0 END),0) AS total_spent
        FROM users u
        LEFT JOIN orders o ON o.user_id=u.id
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
    if (!['Active', 'Blocked'].includes(status)) return res.status(400).json({ success: false, message: 'Status must be Active or Blocked' });
    if (id === req.user.id) return res.status(400).json({ success: false, message: "You can't block your own account." });
    const r = await pool.query('UPDATE users SET is_active=$1 WHERE id=$2 RETURNING id', [status === 'Active', id]);
    if (!r.rows.length) return res.status(404).json({ success: false, message: 'User not found' });
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
    if (id === req.user.id) return res.status(400).json({ success: false, message: "You can't change your own role." });
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

// POST /admin/email/test — sends a test email to the store inbox (or ?to=) so SMTP setup can be verified.
const sendTestEmail = async (req, res, next) => {
  try {
    const { sendMail, isEmailConfigured } = require('../utils/mailer');
    if (!(await isEmailConfigured())) return res.status(400).json({ success: false, message: 'Email is not set up yet. Enter the SMTP details above first.' });
    const inbox = (await pool.query(`SELECT value FROM store_settings WHERE key IN ('store_email','support_email') AND value <> '' ORDER BY key DESC LIMIT 1`)).rows[0]?.value;
    const to = String(req.body?.to || inbox || '').trim();
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(to)) return res.status(400).json({ success: false, message: 'Set a Store Email in Store Information first.' });
    const r = await sendMail({ to, subject: 'ChillFi test email', title: 'Email is working', body: 'Order and alert emails from ChillFi will arrive like this one.' });
    if (!r.sent) return res.status(502).json({ success: false, message: 'The email server rejected the message. Check the SMTP host, port, username and password.' });
    res.json({ success: true, message: `Test email sent to ${to}` });
  } catch (err) { next(err); }
};

// GET /admin/email-templates — every customer/store email, its effective subject/body, and whether it's customised
const getEmailTemplates = async (req, res, next) => {
  try {
    const { listTemplates } = require('../utils/emailTemplates');
    res.json({ success: true, data: await listTemplates() });
  } catch (err) { next(err); }
};

// PUT /admin/email-templates/:key — body: { subject, body }
const updateEmailTemplate = async (req, res, next) => {
  try {
    const { updateTemplate, DEFAULTS } = require('../utils/emailTemplates');
    const { key } = req.params;
    if (!DEFAULTS[key]) return res.status(404).json({ success: false, message: 'Unknown email template' });
    const subject = String(req.body?.subject || '').trim();
    const body = String(req.body?.body || '').trim();
    if (!subject || !body) return res.status(400).json({ success: false, message: 'Subject and body are required' });
    await updateTemplate(key, { subject, body });
    res.json({ success: true, message: 'Template saved' });
  } catch (err) { next(err); }
};

// POST /admin/email-templates/:key/reset — revert to the built-in default wording
const resetEmailTemplate = async (req, res, next) => {
  try {
    const { resetTemplate, DEFAULTS } = require('../utils/emailTemplates');
    const { key } = req.params;
    if (!DEFAULTS[key]) return res.status(404).json({ success: false, message: 'Unknown email template' });
    await resetTemplate(key);
    res.json({ success: true, message: 'Reverted to default' });
  } catch (err) { next(err); }
};

// GET /admin/audit-log — latest admin/staff changes (who, what, when)
const getAuditLog = async (req, res, next) => {
  try {
    const limit = Math.min(Math.max(parseInt(req.query.limit, 10) || 50, 1), 200);
    const r = await pool.query(
      'SELECT id, actor_name, method, path, details, ip, created_at FROM admin_audit_log ORDER BY created_at DESC LIMIT $1', [limit]
    );
    res.json({ success: true, data: { events: r.rows } });
  } catch (err) { next(err); }
};

// GET /admin/login-activity — latest admin / support-staff sign-ins
const getLoginActivity = async (req, res, next) => {
  try {
    const r = await pool.query(`SELECT e.created_at, e.method, e.ip, e.user_agent, u.name, u.role
      FROM admin_login_events e LEFT JOIN users u ON u.id = e.user_id ORDER BY e.created_at DESC LIMIT 30`);
    res.json({ success: true, data: r.rows });
  } catch (err) { next(err); }
};

// GET /admin/launch-status — Go-Live checklist: every launch item's live status, computed from real config.
const SAMPLE = { phone: '+91 98765 43210', gstin: '29AABCU9603R1ZM', address: /tech park, whitefield/i };
const getLaunchStatus = async (req, res, next) => {
  try {
    const fs = require('fs'); const os = require('os'); const path = require('path');
    const phonepe = require('../utils/phonepe');
    const { isEmailConfigured } = require('../utils/mailer');
    const { isSmsConfigured } = require('../utils/sms');
    const { GSTIN_RE } = require('../utils/invoice');
    const s = Object.fromEntries((await pool.query('SELECT key, value FROM store_settings')).rows.map((r) => [r.key, r.value]));
    const pp = await phonepe.getConfig();
    const dl = await delhivery.getConfig();
    const dlMissing = delhivery.configProblems(dl);
    const gstin = String(s.gst_number || '').toUpperCase();
    const items = [];
    const add = (key, title, done, detail, fix, optional = false) => items.push({ key, title, done: !!done, detail, fix, optional });

    add('payments', 'Online payments live (PhonePe)', pp.env === 'PRODUCTION' && !phonepe.configProblems(pp).length,
      pp.env === 'PRODUCTION' ? (phonepe.configProblems(pp).length ? 'PRODUCTION selected but keys missing' : 'Live — real payments accepted')
        : phonepe.sandboxInProduction(pp) ? 'Test mode — online payment is switched off for customers (COD only)' : 'Test (UAT) mode — fine for development', 'apikeys');
    add('shipping', 'Delhivery live shipping', dl.env === 'production' && !dlMissing.length,
      dl.env === 'production' ? (dlMissing.length ? `Production selected but missing: ${dlMissing.join(', ')}` : `Live — pickup location "${dl.pickupLocation || ''}"`)
        : 'Test (staging) mode — orders are not booked with Delhivery for real', 'apikeys');
    add('cod', 'Cash on Delivery', true, s.cod_enabled === 'false' ? 'Switched OFF store-wide' : 'ON — confirm COD is enabled on your live Delhivery account', 'shipping');
    const minV = s.min_app_version || '1.0.0';
    add('app', 'Customers on app v1.0.3+ (force update)', s.force_update_enabled === 'true' && require('../utils/versions').atLeast(minV, '1.0.3'),
      s.force_update_enabled === 'true' ? `Force update ON, minimum ${minV}` : 'Turn on after v1.0.3 is live on Google Play (older app shows GST on top)', 'store');
    add('invoices', 'GST tax invoices', s.invoices_enabled === 'true' && GSTIN_RE.test(gstin) && gstin !== SAMPLE.gstin,
      gstin === SAMPLE.gstin ? 'GSTIN is still the sample value' : !GSTIN_RE.test(gstin) ? 'Enter your 15-character GSTIN' : s.invoices_enabled === 'true' ? 'ON' : 'GSTIN set — switch on "Issue GST Tax Invoices"', 'store');
    const sampleContact = (s.store_phone || '') === SAMPLE.phone || SAMPLE.address.test(s.store_address || '');
    add('contact', 'Real contact details', !sampleContact && !!s.store_phone && !!(s.support_email || s.store_email),
      sampleContact ? 'Phone / address are still sample values' : 'Set', 'store');
    const emailOk = await isEmailConfigured();
    add('email', 'Order emails (SMTP)', emailOk, emailOk ? 'Configured — use "Send test email" to confirm' : 'Not set up — customers get in-app + push only', 'apikeys');
    const smsOk = await isSmsConfigured();
    add('sms', 'SMS order updates (MSG91)', smsOk, smsOk ? 'ON' : 'Optional — needs a DLT-approved template', 'apikeys', true);

    // Backups (nightly timer writes ~/db-backups/backup.log on the server)
    const logFile = process.env.BACKUP_LOG || path.join(os.homedir(), 'db-backups', 'backup.log');
    let lastBackup = null;
    try { const lines = fs.readFileSync(logFile, 'utf8').trim().split('\n'); lastBackup = lines[lines.length - 1]; } catch { /* no log */ }
    const lastAt = lastBackup ? new Date(lastBackup.split(' ')[0]) : null;
    const fresh = lastAt && Date.now() - lastAt.getTime() < 26 * 3600e3;
    add('backups', 'Nightly database backup', fresh, lastAt ? `Last backup ${lastAt.toLocaleString('en-IN', { timeZone: 'Asia/Kolkata' })} (${lastBackup.split(' ').pop()})${fresh ? '' : ' — older than 26 h!'}` : 'No backup found on this server', null);
    add('uptime', 'Uptime monitor (external)', null, 'Can\'t be checked from here — set up UptimeRobot on https://chillfi.in/api/health', null, false);
    items[items.length - 1].manual = true;

    let disk = null;
    try { const st = fs.statfsSync('/'); disk = { free_gb: +(st.bavail * st.bsize / 1e9).toFixed(1), total_gb: +(st.blocks * st.bsize / 1e9).toFixed(1) }; } catch { /* older node */ }
    res.json({ success: true, data: {
      items,
      server: { node: process.version, uptime_h: +(process.uptime() / 3600).toFixed(1), memory_free_mb: Math.round(os.freemem() / 1e6), memory_total_mb: Math.round(os.totalmem() / 1e6), disk },
    } });
  } catch (err) { next(err); }
};

// GET /admin/alerts — actionable counts for the header bell (staff sees only what it can act on).
const getAdminAlerts = async (req, res, next) => {
  try {
    const isAdmin = req.user.role === 'admin';
    const q = await pool.query(`
      SELECT
        (SELECT COUNT(*) FROM orders WHERE status IN ('Pending','Confirmed','Processing')
           AND (shipping_status IS NULL OR shipping_status = 'pending')
           AND (payment_method = 'COD' OR payment_status = 'Paid'))::int AS to_ship,
        (SELECT COUNT(*) FROM orders WHERE status NOT IN ('Cancelled','Delivered') AND shipping_status = 'failed')::int AS failed_shipments,
        (SELECT COUNT(*) FROM refund_requests WHERE status IN ('Requested','Pending','Approved'))::int AS open_refunds,
        (SELECT COUNT(*) FROM contact_messages WHERE is_read = FALSE)::int AS unread_messages,
        (SELECT COUNT(*) FROM products WHERE status <> 'Inactive' AND stock <= 5)::int AS low_stock`);
    const r = q.rows[0];
    const items = [
      { key: 'failed_shipments', count: r.failed_shipments, label: 'shipment(s) failed to create — retry needed', to: '/admin/orders', tone: 'red' },
      { key: 'to_ship', count: r.to_ship, label: 'order(s) waiting to be shipped', to: '/admin/orders', tone: 'orange' },
      ...(isAdmin ? [{ key: 'open_refunds', count: r.open_refunds, label: 'refund request(s) to review', to: '/admin/refunds', tone: 'orange' }] : []),
      { key: 'unread_messages', count: r.unread_messages, label: 'unread customer message(s)', to: '/admin/messages', tone: 'blue' },
      ...(isAdmin ? [{ key: 'low_stock', count: r.low_stock, label: 'product(s) at 5 or fewer in stock', to: '/admin/products', tone: 'gray' }] : []),
    ].filter((i) => i.count > 0);
    res.json({ success: true, data: { items, total: items.reduce((n, i) => n + i.count, 0) } });
  } catch (err) { next(err); }
};

const getShippingRules = async (req, res, next) => {
  try {
    const result = await pool.query('SELECT * FROM shipping_rules ORDER BY pincode_prefix');
    res.json({ success: true, data: result.rows });
  } catch (err) { next(err); }
};

const validateShippingRule = (b) => {
  const has = (k) => b[k] !== undefined && b[k] !== null && b[k] !== '';
  if (b.pincode_prefix !== undefined && !/^[1-9]\d{0,5}$/.test(String(b.pincode_prefix))) return 'Pincode prefix must be 1–6 digits (not starting with 0)';
  if (b.fee !== undefined && (!Number.isFinite(Number(b.fee)) || Number(b.fee) < 0)) return 'Shipping fee cannot be negative';
  if (has('free_above') && (!Number.isFinite(Number(b.free_above)) || Number(b.free_above) < 0)) return 'Free-above amount cannot be negative';
  if (has('estimated_days') && (!Number.isInteger(Number(b.estimated_days)) || Number(b.estimated_days) < 1 || Number(b.estimated_days) > 30)) return 'Estimated days must be between 1 and 30';
  return null;
};
const createShippingRule = async (req, res, next) => {
  try {
    const { pincode_prefix, fee, free_above, cod_available = true, estimated_days = 5, is_active = true } = req.body;
    if (!pincode_prefix || fee === undefined) {
      return res.status(400).json({ success: false, message: 'pincode_prefix and fee are required' });
    }
    const bad = validateShippingRule(req.body);
    if (bad) return res.status(400).json({ success: false, message: bad });
    const result = await pool.query(
      `INSERT INTO shipping_rules (pincode_prefix, fee, free_above, cod_available, estimated_days, is_active)
       VALUES ($1,$2,$3,$4,$5,$6) RETURNING *`,
      [String(pincode_prefix), fee, free_above === '' ? null : free_above ?? null, cod_available, estimated_days || 5, is_active]
    );
    res.status(201).json({ success: true, message: 'Shipping rule created', data: result.rows[0] });
  } catch (err) { next(err); }
};

const updateShippingRule = async (req, res, next) => {
  try {
    const { id } = req.params;
    const bad = validateShippingRule(req.body);
    if (bad) return res.status(400).json({ success: false, message: bad });
    const { pincode_prefix, fee, free_above, cod_available, estimated_days, is_active } = req.body;
    const setFree = free_above !== undefined; // '' or null clears it
    const result = await pool.query(
      `UPDATE shipping_rules SET pincode_prefix=COALESCE($1,pincode_prefix), fee=COALESCE($2,fee),
       free_above=CASE WHEN $8::boolean THEN $3::numeric ELSE free_above END, cod_available=COALESCE($4,cod_available),
       estimated_days=COALESCE($5,estimated_days), is_active=COALESCE($6,is_active)
       WHERE id=$7 RETURNING *`,
      [pincode_prefix ?? null, fee ?? null, setFree && free_above !== '' ? free_above : null, cod_available ?? null, estimated_days || null, is_active ?? null, id, setFree]
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
    if (!result.rows.length) return res.status(404).json({ success: false, message: 'Banner not found' });
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

// Returns an error message or null. partial=true for updates (only validate provided fields).
const COUPON_TYPES = ['Percentage', 'Flat', 'Free Shipping'];
const validateCoupon = (b, partial = false) => {
  const has = (k) => b[k] !== undefined && b[k] !== null && b[k] !== '';
  if (!partial || b.code !== undefined) {
    if (!/^[A-Za-z0-9_-]{3,30}$/.test(String(b.code || '').trim())) return 'Coupon code must be 3–30 letters, numbers, - or _';
  }
  if (!partial || b.type !== undefined) {
    if (!COUPON_TYPES.includes(b.type)) return 'Discount type must be Percentage, Flat or Free Shipping';
  }
  if (!partial || b.value !== undefined) {
    const v = Number(b.value ?? 0);
    if (b.type !== 'Free Shipping' && (!Number.isFinite(v) || v <= 0)) return 'Discount value must be greater than 0';
    if (b.type === 'Percentage' && v > 100) return 'A percentage discount cannot exceed 100%';
  }
  for (const k of ['min_order', 'max_discount']) {
    if (has(k) && (!Number.isFinite(Number(b[k])) || Number(b[k]) < 0)) return `${k === 'min_order' ? 'Minimum order' : 'Max discount'} cannot be negative`;
  }
  const lim = has('usage_limit') ? b.usage_limit : b.total_uses;
  if (lim !== undefined && lim !== null && lim !== '' && (!Number.isInteger(Number(lim)) || Number(lim) < 1)) return 'Usage limit must be a whole number of at least 1 (leave empty for unlimited)';
  if (has('expires_at') && Number.isNaN(Date.parse(b.expires_at))) return 'Expiry date is invalid';
  return null;
};

const createCoupon = async (req, res, next) => {
  try {
    const bad = validateCoupon(req.body);
    if (bad) return res.status(400).json({ success: false, message: bad });
    const { type, value, min_order = 0, max_discount = 0, total_uses, usage_limit, expires_at, is_active = true } = req.body;
    const code = String(req.body.code).trim();
    const existing = await pool.query('SELECT id FROM coupons WHERE code=$1', [code.toUpperCase()]);
    if (existing.rows.length) return res.status(400).json({ success: false, message: 'Coupon code already exists' });

    const usageLimit = usage_limit || total_uses || null;
    const result = await pool.query(
      `INSERT INTO coupons (code, type, value, min_order, max_discount, usage_limit, expires_at, is_active)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8) RETURNING *`,
      [code.toUpperCase(), type, value ?? 0, min_order || 0, max_discount || 0, usageLimit, expires_at || null, is_active]
    );
    res.json({ success: true, message: 'Coupon created', data: result.rows[0] });
  } catch (err) { next(err); }
};

const updateCoupon = async (req, res, next) => {
  try {
    const { id } = req.params;
    const cur = await pool.query('SELECT type FROM coupons WHERE id=$1', [id]);
    if (!cur.rows.length) return res.status(404).json({ success: false, message: 'Coupon not found' });
    const bad = validateCoupon({ ...req.body, type: req.body.type ?? cur.rows[0].type }, true);
    if (bad) return res.status(400).json({ success: false, message: bad });
    const { code, type, value, min_order, max_discount, total_uses, usage_limit, expires_at, is_active } = req.body;
    const limKey = usage_limit !== undefined ? usage_limit : total_uses;
    const setLimit = limKey !== undefined; const setExpiry = expires_at !== undefined;
    const result = await pool.query(
      `UPDATE coupons SET code=COALESCE($1,code), type=COALESCE($2,type), value=COALESCE($3,value),
       min_order=COALESCE($4,min_order), max_discount=COALESCE($5,max_discount),
       usage_limit=CASE WHEN $6::boolean THEN $7::int ELSE usage_limit END,
       expires_at=CASE WHEN $8::boolean THEN $9::timestamptz ELSE expires_at END,
       is_active=COALESCE($10,is_active) WHERE id=$11 RETURNING *`,
      [code ? String(code).trim().toUpperCase() : null, type ?? null, value ?? null, min_order ?? null, max_discount ?? null,
        setLimit, setLimit && limKey !== '' && limKey !== null ? Number(limKey) : null,
        setExpiry, setExpiry && expires_at ? expires_at : null, is_active ?? null, id]
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

const toggleReviewVerified = async (req, res, next) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'UPDATE reviews SET is_verified = NOT is_verified WHERE id=$1 RETURNING is_verified',
      [id]
    );
    if (!result.rows.length) return res.status(404).json({ success: false, message: 'Review not found' });
    res.json({ success: true, data: { is_verified: result.rows[0].is_verified } });
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

// Credential keys and integration-internal keys are never exposed/edited through generic settings.
const isCredentialKey = (key) => CREDENTIAL_KEYS.some((c) => c.key === key) || /^DELHIVERY_|^SHIPROCKET_|^PHONEPE_|^SMTP_|^MSG91_/.test(key);

const getSettings = async (req, res, next) => {
  try {
    const result = await pool.query('SELECT key, value FROM store_settings');
    const data = {};
    // Credentials are served (masked) only by GET /admin/credentials.
    result.rows.forEach(row => { if (!isCredentialKey(row.key)) data[row.key] = row.value; });
    res.json({ success: true, data });
  } catch (err) { next(err); }
};

const updateSettings = async (req, res, next) => {
  try {
    const fields = req.body;
    const keys = Object.keys(fields);
    if (!keys.length) return res.status(400).json({ success: false, message: 'No fields to update' });

    const blocked = keys.filter(isCredentialKey);
    if (blocked.length) {
      return res.status(400).json({ success: false, message: `Use Admin → API Keys to change: ${blocked.join(', ')}` });
    }

    // GST invoices: GSTIN must be valid, and invoices can only be switched on with a valid GSTIN.
    const { GSTIN_RE } = require('../utils/invoice');
    if (fields.gst_number != null && String(fields.gst_number).trim() && !GSTIN_RE.test(String(fields.gst_number).trim().toUpperCase())) {
      return res.status(400).json({ success: false, message: 'GST Number must be a valid 15-character GSTIN (e.g. 07ABCDE1234F1Z5)' });
    }
    if (fields.gst_number != null) fields.gst_number = String(fields.gst_number).trim().toUpperCase();
    if (String(fields.invoices_enabled) === 'true') {
      const gstin = fields.gst_number ?? (await pool.query(`SELECT value FROM store_settings WHERE key = 'gst_number'`)).rows[0]?.value;
      if (!GSTIN_RE.test(String(gstin || '').toUpperCase())) {
        return res.status(400).json({ success: false, message: 'Enter your real GSTIN before turning on tax invoices.' });
      }
    }

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
    result.rows.forEach(row => { if (!isCredentialKey(row.key)) data[row.key] = row.value; });
    res.json({ success: true, message: 'Settings updated', data });
  } catch (err) { next(err); }
};

// ── API Credentials ────────────────────────────────────────────────────────

const CREDENTIAL_KEYS = [
  { key: 'OTP_PROVIDER', label: 'OTP Provider', group: 'otp', secret: false, options: ['firebase', '2factor', 'msg91', 'fast2sms'] },
  { key: 'FIREBASE_WEB_API_KEY', label: 'Firebase Web API Key', group: 'otp', secret: true },
  { key: 'TWO_FACTOR_API_KEY', label: '2Factor.in API Key', group: 'otp', secret: true },
  { key: 'MSG91_AUTH_KEY', label: 'MSG91 Auth Key', group: 'otp', secret: true },
  { key: 'MSG91_TEMPLATE_ID', label: 'MSG91 Template ID', group: 'otp', secret: false },
  { key: 'MSG91_SENDER_ID', label: 'MSG91 Sender ID', group: 'otp', secret: false },
  { key: 'FAST2SMS_API_KEY', label: 'Fast2SMS API Key', group: 'otp', secret: true },
  { key: 'SMS_ORDER_UPDATES', label: 'SMS order updates (MSG91)', group: 'otp', secret: false, options: ['off', 'on'] },
  { key: 'MSG91_ORDER_TEMPLATE_ID', label: 'MSG91 DLT template ID for order updates (vars: order, status)', group: 'otp', secret: false },
  { key: 'SMTP_HOST', label: 'SMTP Host (e.g. smtp.zoho.in, email-smtp.ap-south-1.amazonaws.com)', group: 'email', secret: false },
  { key: 'SMTP_PORT', label: 'SMTP Port (587 = STARTTLS, 465 = SSL)', group: 'email', secret: false },
  { key: 'SMTP_USER', label: 'SMTP Username', group: 'email', secret: false },
  { key: 'SMTP_PASS', label: 'SMTP Password / App Password', group: 'email', secret: true },
  { key: 'EMAIL_FROM', label: 'From address (e.g. ChillFi <orders@chillfi.in>)', group: 'email', secret: false },
  { key: 'FIREBASE_SERVER_KEY', label: 'Firebase Server Key', group: 'firebase', secret: true },
  { key: 'PHONEPE_ENV', label: 'PhonePe Environment (UAT = test, PRODUCTION = live money)', group: 'payment', secret: false, options: ['UAT', 'PRODUCTION'] },
  { key: 'PHONEPE_MERCHANT_ID', label: 'PhonePe Merchant ID', group: 'payment', secret: false },
  { key: 'PHONEPE_SALT_KEY', label: 'PhonePe Salt Key', group: 'payment', secret: true },
  { key: 'PHONEPE_SALT_INDEX', label: 'PhonePe Salt Index', group: 'payment', secret: false },
  { key: 'RAZORPAY_KEY_ID', label: 'Razorpay Key ID', group: 'payment', secret: false },
  { key: 'RAZORPAY_KEY_SECRET', label: 'Razorpay Key Secret', group: 'payment', secret: true },
  { key: 'CLOUDINARY_CLOUD_NAME', label: 'Cloudinary Cloud Name', group: 'media', secret: false },
  { key: 'CLOUDINARY_API_KEY', label: 'Cloudinary API Key', group: 'media', secret: false },
  { key: 'CLOUDINARY_API_SECRET', label: 'Cloudinary API Secret', group: 'media', secret: true },
  { key: 'DELHIVERY_ENV', label: 'Delhivery Environment', group: 'shipping', secret: false, options: ['staging', 'production'] },
  { key: 'DELHIVERY_AUTO_SHIP', label: 'Auto-create Delhivery shipment for new orders', group: 'shipping', secret: false, options: ['true', 'false'] },
  { key: 'DELHIVERY_STAGING_TOKEN', label: 'Delhivery STAGING API Token', group: 'shipping', secret: true },
  { key: 'DELHIVERY_STAGING_PICKUP_LOCATION', label: 'Delhivery STAGING Pickup Location (exact name)', group: 'shipping', secret: false },
  { key: 'DELHIVERY_TOKEN', label: 'Delhivery PRODUCTION API Token', group: 'shipping', secret: true },
  { key: 'DELHIVERY_PICKUP_LOCATION', label: 'Delhivery PRODUCTION Pickup Location (exact name)', group: 'shipping', secret: false },
  { key: 'DELHIVERY_CLIENT_NAME', label: 'Delhivery Seller / Client Name', group: 'shipping', secret: false },
  { key: 'DELHIVERY_SELLER_GST', label: 'Seller GSTIN (sent on shipments)', group: 'shipping', secret: false },
  { key: 'DELHIVERY_DEFAULT_WEIGHT_GRAMS', label: 'Default package weight (grams)', group: 'shipping', secret: false },
  { key: 'DELHIVERY_AUTO_PICKUP', label: 'Auto-book Delhivery pickup after shipment creation', group: 'shipping', secret: false, options: ['true', 'false'] },
  { key: 'DELHIVERY_PICKUP_TIME', label: 'Pickup time (HH:MM, IST) — default 14:00', group: 'shipping', secret: false },
  { key: 'DELHIVERY_PICKUP_CUTOFF', label: 'Same-day pickup cut-off (HH:MM, IST) — default 12:00', group: 'shipping', secret: false },
  { key: 'DELHIVERY_WEBHOOK_SECRET', label: 'Delhivery Webhook Secret (Bearer token Delhivery sends)', group: 'shipping', secret: true },
  { key: 'SHIPROCKET_EMAIL', label: 'Shiprocket Login Email', group: 'shipping', secret: false },
  { key: 'SHIPROCKET_PASSWORD', label: 'Shiprocket Password', group: 'shipping', secret: true },
  { key: 'SHIPROCKET_PICKUP_LOCATION', label: 'Shiprocket Pickup Location Name', group: 'shipping', secret: false },
  { key: 'SHIPROCKET_CHANNEL_ID', label: 'Shiprocket Channel ID (optional)', group: 'shipping', secret: false },
];

const { setSetting, decryptValue } = require('../utils/settings');
const delhivery = require('../utils/delhivery');
const shipmentService = require('../services/shipmentService');
const { invalidateToken: invalidateShiprocketToken } = require('../utils/shiprocket');

const getCredentials = async (req, res, next) => {
  try {
    const result = await pool.query('SELECT key, value FROM store_settings');
    const dbVals = {};
    result.rows.forEach(r => { dbVals[r.key] = r.value; });

    const data = CREDENTIAL_KEYS.map(meta => {
      const rawVal = decryptValue(dbVals[meta.key]) || process.env[meta.key] || '';
      // Secrets never leave the server; only the last 4 chars are shown for identification.
      const maskedVal = meta.secret && rawVal ? `••••••••${rawVal.length > 8 ? rawVal.slice(-4) : ''}` : rawVal;
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

    if (meta.options && value && !meta.options.includes(value)) {
      return res.status(400).json({ success: false, message: `${meta.label} must be one of: ${meta.options.join(', ')}` });
    }
    await setSetting(key, typeof value === 'string' ? value.trim() : value, { secret: !!meta.secret });
    console.log(`[admin] ${req.user.id} updated credential ${key}${meta.secret ? ' (secret)' : `=${value}`}`);
    // Bust Shiprocket token cache whenever email or password changes
    if (key === 'SHIPROCKET_EMAIL' || key === 'SHIPROCKET_PASSWORD') invalidateShiprocketToken();

    res.json({ success: true, message: `${meta.label} updated` });
  } catch (err) { next(err); }
};

// ── Delhivery integration health ──────────────────────────────────────────

// GET /api/admin/shipping/delhivery/status
const getDelhiveryStatus = async (req, res, next) => {
  try {
    const cfg = await delhivery.getConfig();
    const missing = delhivery.configProblems(cfg);
    const [counts, lastEvent, webhookLast, webhookSecret, autoShip] = await Promise.all([
      pool.query(`SELECT COALESCE(shipping_status, 'none') AS s, COUNT(*)::int AS n FROM orders
                  WHERE created_at > NOW() - INTERVAL '90 days' GROUP BY 1`),
      pool.query(`SELECT source, created_at FROM shipment_events ORDER BY created_at DESC LIMIT 1`),
      pool.query(`SELECT value FROM store_settings WHERE key = 'DELHIVERY_WEBHOOK_LAST_RECEIVED'`),
      pool.query(`SELECT 1 FROM store_settings WHERE key = 'DELHIVERY_WEBHOOK_SECRET' AND value IS NOT NULL`),
      pool.query(`SELECT value FROM store_settings WHERE key = 'DELHIVERY_AUTO_SHIP'`),
    ]);
    const lastPickup = (await pool.query(`SELECT value FROM store_settings WHERE key = 'DELHIVERY_LAST_PICKUP'`)).rows[0]?.value;
    const awaitingPickup = (await pool.query(`SELECT COUNT(*)::int n FROM orders WHERE shipping_status IN ('manifested','pickup_pending') AND status <> 'Cancelled'`)).rows[0].n;
    const failed = await pool.query(`SELECT id, order_number, shipment_error, shipment_attempts FROM orders
      WHERE shipping_status = 'failed' AND status = 'Processing' ORDER BY updated_at DESC LIMIT 20`);
    const apiBase = process.env.APP_BASE_URL || `${req.protocol}://${req.get('host')}`;
    res.json({
      success: true,
      data: {
        provider: 'delhivery',
        environment: cfg.env,
        configured: missing.length === 0,
        missing,
        pickup_location: cfg.pickupLocation || null,
        base_url: cfg.baseUrl,
        auto_ship: autoShip.rows[0]?.value !== 'false',
        webhook: {
          url: `${apiBase.replace(/\/$/, '')}/api/shipping/delhivery/webhook`,
          secret_set: !!webhookSecret.rows.length || !!process.env.DELHIVERY_WEBHOOK_SECRET,
          last_received: webhookLast.rows[0]?.value || null,
        },
        last_event: lastEvent.rows[0] || null,
        pickup: { last: lastPickup ? JSON.parse(lastPickup) : null, awaiting_pickup: awaitingPickup },
        last_scheduled_sync: shipmentService.lastRun,
        shipping_status_counts: Object.fromEntries(counts.rows.map((r) => [r.s, r.n])),
        failed_shipments: failed.rows,
      },
    });
  } catch (err) { next(err); }
};

// POST /api/admin/shipping/delhivery/test  { pincode? }
const testDelhiveryConnection = async (req, res, next) => {
  try {
    const r = await delhivery.testConnection(req.body?.pincode || '110001');
    res.status(r.ok ? 200 : 502).json({ success: r.ok, message: r.message, data: r });
  } catch (err) { next(err); }
};

// POST /api/admin/shipping/delhivery/pickup — book (or confirm) a pickup for parcels waiting at the warehouse
const requestDelhiveryPickup = async (req, res, next) => {
  try {
    const r = await shipmentService.ensurePickup({ trigger: 'admin' });
    res.status(r.ok ? 200 : 502).json({ success: !!r.ok, message: r.ok ? (r.existing ? 'Pickup already booked for this warehouse' : `Pickup booked for ${r.date} ${r.time}`) : r.error, data: r });
  } catch (err) { next(err); }
};

// POST /api/admin/shipping/delhivery/sync — sync all active shipments + retry failed creations now
const syncDelhiveryNow = async (req, res, next) => {
  try {
    await shipmentService.runScheduledSync();
    res.json({ success: true, data: shipmentService.lastRun });
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
    const { cloudinary, configureCloudinary } = require('../middleware/upload');
    await configureCloudinary();
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
  getAdminAlerts, sendTestEmail, getLoginActivity, getAuditLog, getLaunchStatus,
  getDashboardStats, getAnalytics,
  getUsers, updateUserStatus, updateUserRole,
  getBanners, createBanner, updateBanner, deleteBanner,
  getShippingRules, createShippingRule, updateShippingRule, deleteShippingRule,
  getTestimonials, createTestimonial, updateTestimonial, deleteTestimonial,
  getPromoBanners, createPromoBanner, updatePromoBanner, deletePromoBanner,
  getCoupons, createCoupon, updateCoupon, deleteCoupon,
  getReviews, deleteReview, toggleReviewVerified,
  getMessages, updateMessageReadStatus, replyToMessage, deleteMessage,
  getSettings, updateSettings,
  getCredentials, updateCredentials,
  getEmailTemplates, updateEmailTemplate, resetEmailTemplate,
  uploadImage, deleteImage,
  sendPushNotification,
  getDelhiveryStatus, testDelhiveryConnection, syncDelhiveryNow, requestDelhiveryPickup,
};
