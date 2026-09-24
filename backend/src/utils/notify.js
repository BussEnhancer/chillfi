const pool = require('../db/pool');
const { getSetting } = require('./settings');
const { sendPushToTokens } = require('./firebase');

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
    const prefs = await pool.query('SELECT notification_preferences FROM users WHERE id = $1', [userId]);
    const userEnabled = prefs.rows[0]?.notification_preferences?.orderUpdates !== false;

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
    console.log(`[notify] user=${userId} type=${type} key=${dedupeKey || '-'} push=${JSON.stringify(push)}`);
    return { inserted: true, push };
  } catch (err) {
    console.error(`[notify] failed user=${userId} key=${dedupeKey || '-'}: ${err.message}`);
    return { inserted: false, error: err.message };
  }
};

module.exports = { notifyUser };
