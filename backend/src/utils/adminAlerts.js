// Emails to the store (Settings → Store Email / Support Email). Switches: notify_admin_alerts, notify_low_stock.
const pool = require('../db/pool');
const { sendMail } = require('./mailer');
const { renderTemplate } = require('./emailTemplates');

const LOW_STOCK = 5;
const storeInbox = async () => {
  const r = await pool.query(`SELECT key, value FROM store_settings WHERE key IN ('store_email','support_email','notify_admin_alerts','notify_low_stock')`);
  const s = Object.fromEntries(r.rows.map((x) => [x.key, x.value]));
  return { to: s.store_email || s.support_email || null, alerts: s.notify_admin_alerts !== 'false', lowStock: s.notify_low_stock !== 'false' };
};
const adminUrl = (p) => `${(process.env.WEBSITE_URL || process.env.APP_BASE_URL || 'https://chillfi.in').replace(/\/$/, '')}${p}`;

/** New confirmed order → email the store. Never throws. */
const newOrderAlert = async (order) => {
  try {
    const box = await storeInbox();
    if (!box.alerts || !box.to) return { sent: false };
    const { subject, body } = await renderTemplate('new_order_admin_alert', {
      order_number: order.order_number, total: order.total, payment_method: order.payment_method,
    });
    return await sendMail({
      to: box.to, subject, title: `New order ${order.order_number}`, body,
      ctaText: 'Open orders', ctaUrl: adminUrl('/admin/orders'),
    });
  } catch { return { sent: false }; }
};

/** Products that just crossed into low stock (were above the limit before this order). Never throws. */
const lowStockAlert = async (crossed) => {
  try {
    if (!crossed.length) return { sent: false };
    const box = await storeInbox();
    if (!box.lowStock || !box.to) return { sent: false };
    const product_names = crossed.map((c) => c.name).slice(0, 3).join(', ') + (crossed.length > 3 ? '…' : '');
    const product_list = crossed.map((c) => `${c.name}: ${c.stock} left`).join(' · ');
    const { subject, body } = await renderTemplate('low_stock_alert', { product_names, product_list });
    return await sendMail({
      to: box.to, subject, title: 'Low stock alert', body,
      ctaText: 'Open products', ctaUrl: adminUrl('/admin/products'),
    });
  } catch { return { sent: false }; }
};

module.exports = { newOrderAlert, lowStockAlert, LOW_STOCK };
