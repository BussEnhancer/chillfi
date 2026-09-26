// Admin-editable subject/body for every customer + store email (Settings → Email Templates).
// A template with no row in email_templates just uses the built-in default below — nothing breaks
// until an admin actually customises one.
const pool = require('../db/pool');

const CACHE_TTL = 30000;
let cache = { at: 0, rows: null };

const DEFAULTS = {
  order_confirmed: {
    label: 'Order confirmed', group: 'Order updates',
    subject: 'Order confirmed', body: 'Your order {{order_number}} for ₹{{total}} has been placed.',
    placeholders: ['order_number', 'total'],
  },
  shipment_manifested: {
    label: 'Shipment created', group: 'Order updates',
    subject: 'Shipment created', body: 'Your order {{order_number}} is packed and handed to Delhivery. AWB: {{tracking_id}}',
    placeholders: ['order_number', 'tracking_id'],
  },
  order_shipped: {
    label: 'Order shipped', group: 'Order updates',
    subject: 'Order shipped', body: 'Your order {{order_number}} has been picked up and is on its way.',
    placeholders: ['order_number'],
  },
  order_out_for_delivery: {
    label: 'Out for delivery', group: 'Order updates',
    subject: 'Out for delivery', body: 'Your order {{order_number}} is out for delivery today.',
    placeholders: ['order_number'],
  },
  order_delivered: {
    label: 'Order delivered', group: 'Order updates',
    subject: 'Order delivered', body: 'Your order {{order_number}} has been delivered. Enjoy!',
    placeholders: ['order_number'],
  },
  delivery_attempt_failed: {
    label: 'Delivery attempt failed', group: 'Order updates',
    subject: 'Delivery attempt unsuccessful', body: 'Delhivery could not deliver order {{order_number}}{{instructions}}. They will re-attempt.',
    placeholders: ['order_number', 'instructions'],
  },
  shipment_returning: {
    label: 'Return in progress', group: 'Order updates',
    subject: 'Delivery unsuccessful', body: "We couldn't deliver order {{order_number}}; it is being returned. Contact support if this is unexpected.",
    placeholders: ['order_number'],
  },
  order_returned: {
    label: 'Order returned', group: 'Order updates',
    subject: 'Order returned', body: 'Order {{order_number}} was returned to us. Any refund due will be processed.',
    placeholders: ['order_number'],
  },
  shipment_cancelled: {
    label: 'Shipment cancelled', group: 'Order updates',
    subject: 'Shipment cancelled', body: 'The shipment for order {{order_number}} was cancelled.',
    placeholders: ['order_number'],
  },
  order_cancelled: {
    label: 'Order cancelled (by customer)', group: 'Order updates',
    subject: 'Order cancelled', body: 'Your order {{order_number}} has been cancelled.',
    placeholders: ['order_number'],
  },
  order_cancelled_unpaid: {
    label: 'Order cancelled (payment not completed)', group: 'Order updates',
    subject: 'Order cancelled — payment not completed',
    body: "We didn't receive payment for order {{order_number}}, so it has been cancelled. If any amount was deducted, it will be refunded automatically.",
    placeholders: ['order_number'],
  },
  new_order_admin_alert: {
    label: 'New order alert (to store)', group: 'Store alerts',
    subject: 'New order {{order_number}} — ₹{{total}} ({{payment_method}})',
    body: 'A {{payment_method}} order for ₹{{total}} has been confirmed. Open the admin panel to review and ship it.',
    placeholders: ['order_number', 'total', 'payment_method'],
  },
  low_stock_alert: {
    label: 'Low stock alert (to store)', group: 'Store alerts',
    subject: 'Low stock: {{product_names}}', body: '{{product_list}}',
    placeholders: ['product_names', 'product_list'],
  },
};

const render = (str, vars) => String(str || '').replace(/\{\{(\w+)\}\}/g, (_, k) => (vars[k] ?? ''));

const loadAll = async () => {
  if (cache.rows && Date.now() - cache.at < CACHE_TTL) return cache.rows;
  const r = await pool.query('SELECT key, subject, body FROM email_templates');
  const rows = Object.fromEntries(r.rows.map((x) => [x.key, x]));
  cache = { at: Date.now(), rows };
  return rows;
};

const invalidateCache = () => { cache = { at: 0, rows: null }; };

/** For the admin UI: every template, its current effective subject/body, and whether it's customised. */
const listTemplates = async () => {
  const rows = await loadAll();
  return Object.entries(DEFAULTS).map(([key, def]) => {
    const custom = rows[key];
    return {
      key, label: def.label, group: def.group, placeholders: def.placeholders,
      subject: custom?.subject ?? def.subject,
      body: custom?.body ?? def.body,
      defaultSubject: def.subject, defaultBody: def.body,
      isCustom: !!custom,
    };
  });
};

/** Used by the code that actually sends each email/notification. */
const renderTemplate = async (key, vars = {}) => {
  const def = DEFAULTS[key];
  if (!def) throw new Error(`Unknown email template: ${key}`);
  const rows = await loadAll();
  const custom = rows[key];
  return {
    subject: render(custom?.subject ?? def.subject, vars),
    body: render(custom?.body ?? def.body, vars),
  };
};

const updateTemplate = async (key, { subject, body }) => {
  if (!DEFAULTS[key]) throw new Error(`Unknown email template: ${key}`);
  await pool.query(
    `INSERT INTO email_templates (key, subject, body, updated_at) VALUES ($1, $2, $3, NOW())
     ON CONFLICT (key) DO UPDATE SET subject = $2, body = $3, updated_at = NOW()`,
    [key, subject, body]
  );
  invalidateCache();
};

const resetTemplate = async (key) => {
  if (!DEFAULTS[key]) throw new Error(`Unknown email template: ${key}`);
  await pool.query('DELETE FROM email_templates WHERE key = $1', [key]);
  invalidateCache();
};

module.exports = { DEFAULTS, listTemplates, renderTemplate, updateTemplate, resetTemplate, invalidateCache };
