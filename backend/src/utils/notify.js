const pool = require('../db/pool');
const { getSetting } = require('./settings');
const { sendPushToTokens } = require('./firebase');
const { sendMail } = require('./mailer');
const { sendOrderSms } = require('./sms');

// SMS only for the moments a customer really needs (cost + DLT template limits).
const SMS_WORTHY = (data = {}, key = '') => /:placed$|:cancelled$/.test(key || '')
  || ['in_transit', 'shipped', 'out_for_delivery', 'delivered'].includes(data.shipping_status);
const siteUrl = () => (process.env.WEBSITE_URL || process.env.APP_BASE_URL || 'https://chillfi.in').replace(/\/$/, '');

// Maps an order notification to the customer's per-stage toggle (Notification Settings in the app).
// Cancellations and failed-delivery alerts are always sent: they need the customer's attention.
const STAGE_PREF = {
  manifested: 'orderProcessing', pickup_pending: 'orderProcessing', picked_up: 'orderProcessing',
  in_transit: 'shippingUpdates', at_destination_hub: 'shippingUpdates', shipped: 'shippingUpdates',
  out_for_delivery: 'outForDelivery', delivered: 'delivered',
};
const userPrefKeyFor = (data = {}, dedupeKey = '') => {
  if (data.shipping_status && STAGE_PREF[data.shipping_status]) return STAGE_PREF[data.shipping_status];
  if (/:placed$/.test(dedupeKey || '')) return 'orderConfirmation';
  return null;
};

/**
 * Records an in-app notification and (if enabled) sends an FCM push.
 * dedupeKey makes this idempotent: a retried courier webhook for the same event
 * never produces a second notification or push.
 * storeSettingKey: admin-level toggle (e.g. notify_order_shipped) — gates push only;
 * the in-app record is always written so order history stays complete.
 * Never throws — notification failure must not break order/shipping flows.
 */
const notifyUser = async (userId, { title, body, type = 'order', data = {}, dedupeKey = null, storeSettingKey = null }) => {
  if (!userId) return { inserted: false };
  try {
    const ins = await pool.query(
      `INSERT INTO notifications (user_id, title, body, type, data, dedupe_key)
       VALUES ($1,$2,$3,$4,$5,$6)
       ON CONFLICT (dedupe_key) WHERE dedupe_key IS NOT NULL DO NOTHING
       RETURNING id`,
      [userId, title, body, type, JSON.stringify(data), dedupeKey]
    );
    if (!ins.rows.length) return { inserted: false, duplicate: true };

    let push = { attempted: false };
    const adminEnabled = storeSettingKey ? (await getSetting(storeSettingKey)) !== 'false' : true;
    const prefs = await pool.query('SELECT notification_preferences, email, phone FROM users WHERE id = $1', [userId]);
    const userPrefs = prefs.rows[0]?.notification_preferences || {};
    const prefKey = userPrefKeyFor(data, dedupeKey);
    // orderUpdates is the legacy master switch; per-stage keys come from the app's Notification Settings.
    const userEnabled = userPrefs.orderUpdates !== false && (!prefKey || userPrefs[prefKey] !== false);

    if (adminEnabled && userEnabled) {
      const tokens = (await pool.query('SELECT token FROM fcm_tokens WHERE user_id = $1', [userId])).rows.map((r) => r.token);
      if (tokens.length) {
        const stringData = Object.fromEntries(Object.entries({ type, ...data }).map(([k, v]) => [k, String(v ?? '')]));
        const r = await sendPushToTokens(tokens, { title, body, data: stringData });
        if (r.invalidTokens.length) await pool.query('DELETE FROM fcm_tokens WHERE token = ANY($1::text[])', [r.invalidTokens]);
        push = { attempted: true, successCount: r.successCount, failureCount: r.failureCount };
      } else {
        push = { attempted: false, reason: 'no FCM token' };
      }
    }
    // Email + SMS follow the same admin switch and customer preferences as push; both are no-ops until configured.
    let email = { attempted: false }; let sms = { attempted: false };
    if (adminEnabled && userEnabled) {
      const u = prefs.rows[0] || {};
      const ctaUrl = data.order_id ? `${siteUrl()}/account/orders/${data.order_id}/track` : null;
      if (u.email && userPrefs.emailUpdates !== false) {
        email = { attempted: true, ...(await sendMail({ to: u.email, subject: title, title, body, ctaText: 'View your order', ctaUrl })) };
      }
      if (type === 'order' && u.phone && userPrefs.smsUpdates !== false && SMS_WORTHY(data, dedupeKey)) {
        sms = { attempted: true, ...(await sendOrderSms({ phone: u.phone, orderNumber: data.order_number || '', status: title })) };
      }
    }
    console.log(`[notify] user=${userId} type=${type} key=${dedupeKey || '-'} push=${JSON.stringify(push)} email=${email.sent ? 'sent' : email.reason || '-'} sms=${sms.sent ? 'sent' : sms.reason || '-'}`);
    return { inserted: true, push, email, sms };
  } catch (err) {
    console.error(`[notify] failed user=${userId} key=${dedupeKey || '-'}: ${err.message}`);
    return { inserted: false, error: err.message };
  }
};

module.exports = { notifyUser };
