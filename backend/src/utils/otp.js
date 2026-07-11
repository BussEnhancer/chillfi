const axios = require('axios');
const pool = require('../db/pool');
const { getSetting } = require('./settings');

const MAX_OTP_ATTEMPTS = 5;

// Test numbers that always get OTP 123456, no SMS sent
const TEST_PHONES = new Set(['9876543210']);

const generateOTP = () => Math.floor(100000 + Math.random() * 900000).toString();

const checkOtpRateLimit = async (phone) => {
  const result = await pool.query(
    `SELECT
       COUNT(*) FILTER (WHERE created_at > NOW() - INTERVAL '60 seconds') AS recent,
       COUNT(*) FILTER (WHERE created_at > NOW() - INTERVAL '1 hour') AS hourly
     FROM otp_sessions WHERE phone = $1`,
    [phone]
  );
  const { recent, hourly } = result.rows[0];
  if (parseInt(recent, 10) > 0) {
    return { allowed: false, message: 'Please wait a minute before requesting another OTP' };
  }
  if (parseInt(hourly, 10) >= 5) {
    return { allowed: false, message: 'Too many OTP requests. Please try again later.' };
  }
  return { allowed: true };
};

const sendVia2Factor = async (phone, otp, apiKey) => {
  const url = `https://2factor.in/API/V1/${apiKey}/SMS/91${phone}/AUTOGEN/2FA/${otp}`;
  const response = await axios.get(url);
  if (response.data?.Status === 'Success') {
    console.log('✅ 2Factor SMS sent');
    return true;
  }
  throw new Error(response.data?.Details || 'Unknown 2Factor error');
};

const sendViaMSG91 = async (phone, otp, authKey, templateId) => {
  const response = await axios.post(
    'https://api.msg91.com/api/v5/otp',
    { template_id: templateId, mobile: `91${phone}`, otp },
    { headers: { authkey: authKey, 'Content-Type': 'application/json' } }
  );
  console.log('✅ MSG91 SMS sent:', response.data);
  return true;
};

const sendOTP = async (phone, otp) => {
  if (process.env.NODE_ENV !== 'production') {
    console.log(`📱 OTP for ${phone}: ${otp}`);
  }

  const provider = await getSetting('OTP_PROVIDER') || '2factor';

  try {
    if (provider === 'msg91') {
      const authKey = await getSetting('MSG91_AUTH_KEY');
      const templateId = await getSetting('MSG91_TEMPLATE_ID');
      if (!authKey || authKey === 'your_msg91_auth_key' || !templateId || templateId === 'your_msg91_template_id') {
        console.log('⚠️  MSG91 credentials not configured');
        return true;
      }
      return await sendViaMSG91(phone, otp, authKey, templateId);
    }

    // Default: 2Factor.in
    const apiKey = await getSetting('TWO_FACTOR_API_KEY');
    if (!apiKey || apiKey === 'your_2factor_api_key') {
      console.log('⚠️  2Factor.in API key not configured — OTP not sent via SMS');
      return true;
    }
    return await sendVia2Factor(phone, otp, apiKey);
  } catch (err) {
    console.error('❌ OTP SMS error:', err.response?.data || err.message);
    return false;
  }
};

const createOTPSession = async (phone, purpose = 'login') => {
  const isTest = TEST_PHONES.has(phone);
  const otp = isTest ? '123456' : generateOTP();
  const expiresAt = new Date(Date.now() + 10 * 60 * 1000); // 10 min

  await pool.query(
    `UPDATE otp_sessions SET is_used = TRUE WHERE phone = $1 AND purpose = $2 AND is_used = FALSE`,
    [phone, purpose]
  );
  await pool.query(
    `DELETE FROM otp_sessions WHERE phone = $1 AND (is_used = TRUE OR expires_at < NOW())`,
    [phone]
  );
  await pool.query(
    `INSERT INTO otp_sessions (phone, otp, purpose, expires_at) VALUES ($1, $2, $3, $4)`,
    [phone, otp, purpose, expiresAt]
  );

  if (!isTest) await sendOTP(phone, otp);
  else console.log(`🧪 Test OTP for ${phone}: ${otp}`);
  return otp;
};

const verifyOTP = async (phone, otp, purpose = 'login') => {
  const result = await pool.query(
    `SELECT id, otp, attempts FROM otp_sessions
     WHERE phone = $1 AND purpose = $2
       AND is_used = FALSE AND expires_at > NOW()
     ORDER BY created_at DESC LIMIT 1`,
    [phone, purpose]
  );

  if (!result.rows.length) return false;
  const session = result.rows[0];

  if (session.attempts >= MAX_OTP_ATTEMPTS) {
    await pool.query(`UPDATE otp_sessions SET is_used = TRUE WHERE id = $1`, [session.id]);
    return false;
  }

  if (session.otp !== otp) {
    await pool.query(`UPDATE otp_sessions SET attempts = attempts + 1 WHERE id = $1`, [session.id]);
    return false;
  }

  await pool.query(`UPDATE otp_sessions SET is_used = TRUE WHERE id = $1`, [session.id]);
  return true;
};

module.exports = { createOTPSession, verifyOTP, checkOtpRateLimit };
