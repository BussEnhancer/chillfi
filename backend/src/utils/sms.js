// Order-update SMS via MSG91 Flow (India: needs a DLT-approved template with variables ##order## and ##status##).
// Off unless SMS_ORDER_UPDATES = on and MSG91_AUTH_KEY + MSG91_ORDER_TEMPLATE_ID are set.
const axios = require('axios');
const { getSetting } = require('./settings');

const isSmsConfigured = async () => {
  const [on, key, tpl] = await Promise.all(['SMS_ORDER_UPDATES', 'MSG91_AUTH_KEY', 'MSG91_ORDER_TEMPLATE_ID'].map(getSetting));
  return on === 'on' && !!key && !/^your/i.test(key) && !!tpl;
};

/** Never throws. phone = 10-digit Indian mobile. */
const sendOrderSms = async ({ phone, orderNumber, status }) => {
  try {
    if (!(await isSmsConfigured())) return { sent: false, reason: 'sms not configured' };
    const digits = String(phone || '').replace(/\D/g, '').replace(/^91(?=\d{10}$)/, '');
    if (!/^[6-9]\d{9}$/.test(digits)) return { sent: false, reason: 'invalid phone' };
    const [key, tpl] = await Promise.all([getSetting('MSG91_AUTH_KEY'), getSetting('MSG91_ORDER_TEMPLATE_ID')]);
    const base = process.env.MSG91_BASE_URL || 'https://control.msg91.com';
    const r = await axios.post(`${base}/api/v5/flow`, {
      template_id: tpl, short_url: '0',
      recipients: [{ mobiles: `91${digits}`, order: orderNumber, status }],
    }, { headers: { authkey: key, 'Content-Type': 'application/json' }, timeout: 10000 });
    const ok = r.data?.type === 'success';
    if (!ok) console.warn(`[sms] MSG91 rejected: ${r.data?.message || 'unknown'}`);
    return { sent: ok };
  } catch (err) {
    console.error(`[sms] send failed: ${err.response?.status || ''} ${err.message}`);
    return { sent: false, reason: 'send failed' };
  }
};

module.exports = { sendOrderSms, isSmsConfigured };
