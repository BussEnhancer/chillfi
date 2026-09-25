const axios = require('axios');
const crypto = require('crypto');
const pool = require('../db/pool');
const { getSetting } = require('./settings');

const MAX_OTP_ATTEMPTS = 5;

// Test numbers that always get OTP 123456, no SMS sent — development only (never on a production server).
const TEST_PHONES = process.env.NODE_ENV === 'production' ? new Set() : new Set(['9876543210']);

const generateOTP = () => crypto.randomInt(100000, 1000000).toString();

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

// ─── SMS Providers ────────────────────────────────────────────────────────────

const sendVia2Factor = async (phone, otp, apiKey) => {
  const url = `https://2factor.in/API/V1/${apiKey}/SMS/91${phone}/AUTOGEN/2FA/${otp}`;
  const response = await axios.get(url);
  if (response.data?.Status === 'Success') { console.log('✅ 2Factor SMS sent'); return true; }
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

const sendViaFast2SMS = async (phone, otp, apiKey) => {
  const response = await axios.post(
    'https://www.fast2sms.com/dev/bulkV2',
    { variables_values: otp, route: 'otp', numbers: phone },
    { headers: { authorization: apiKey } }
  );
  if (response.data?.return) { console.log('✅ Fast2SMS sent'); return true; }
  throw new Error(response.data?.message || 'Unknown Fast2SMS error');
};

// ─── Firebase Phone Auth via REST API ────────────────────────────────────────
// Returns sessionInfo (used later in verifyViaFirebase).
// Pass an optional clientToken (recaptchaToken for web, safetyNetToken for Android).
const sendViaFirebase = async (phone, webApiKey, clientToken = '') => {
  const url = `https://identitytoolkit.googleapis.com/v1/accounts:sendVerificationCode?key=${webApiKey}`;
  const response = await axios.post(url, {
    phoneNumber: `+91${phone}`,
    recaptchaToken: clientToken,
  });
  const sessionInfo = response.data?.sessionInfo;
  if (!sessionInfo) throw new Error('Firebase did not return sessionInfo');
  console.log('✅ Firebase OTP sent');
  return sessionInfo;
};

const verifyViaFirebase = async (sessionInfo, code, webApiKey) => {
  const url = `https://identitytoolkit.googleapis.com/v1/accounts:signInWithPhoneNumber?key=${webApiKey}`;
  const response = await axios.post(url, { sessionInfo, code });
  return !!response.data?.idToken;
};

// ─── Dispatcher ──────────────────────────────────────────────────────────────
// Returns { sent: true, sessionInfo? } — sessionInfo only for Firebase provider.
const sendOTP = async (phone, otp, clientToken = '') => {
  if (process.env.NODE_ENV !== 'production') {
    console.log(`📱 OTP for ${phone}: ${otp}`);
  }

  const provider = await getSetting('OTP_PROVIDER') || 'firebase';

  try {
    if (provider === 'firebase') {
      const webApiKey = await getSetting('FIREBASE_WEB_API_KEY');
      if (!webApiKey) { console.log('⚠️  FIREBASE_WEB_API_KEY not set'); return { sent: true }; }
      const sessionInfo = await sendViaFirebase(phone, webApiKey, clientToken);
      return { sent: true, sessionInfo };
    }

    if (provider === 'msg91') {
      const authKey = await getSetting('MSG91_AUTH_KEY');
      const templateId = await getSetting('MSG91_TEMPLATE_ID');
      if (!authKey || !templateId) { console.log('⚠️  MSG91 credentials not configured'); return { sent: true }; }
      await sendViaMSG91(phone, otp, authKey, templateId);
      return { sent: true };
    }

    if (provider === 'fast2sms') {
      const apiKey = await getSetting('FAST2SMS_API_KEY');
      if (!apiKey) { console.log('⚠️  FAST2SMS_API_KEY not configured'); return { sent: true }; }
      await sendViaFast2SMS(phone, otp, apiKey);
      return { sent: true };
    }

    // Default: 2Factor.in
    const apiKey = await getSetting('TWO_FACTOR_API_KEY');
    if (!apiKey || apiKey === 'your_2factor_api_key') {
      console.log('⚠️  2Factor.in API key not configured');
      return { sent: true };
    }
    await sendVia2Factor(phone, otp, apiKey);
    return { sent: true };
  } catch (err) {
    console.error('❌ OTP SMS error:', err.response?.data || err.message);
    return { sent: false };
  }
};

// clientToken: optional reCAPTCHA/SafetyNet token forwarded from client (Firebase provider only)
const createOTPSession = async (phone, purpose = 'login', clientToken = '') => {
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

  if (isTest) {
    await pool.query(
      `INSERT INTO otp_sessions (phone, otp, purpose, expires_at) VALUES ($1, $2, $3, $4)`,
      [phone, otp, purpose, expiresAt]
    );
    console.log(`🧪 Test OTP for ${phone}: ${otp}`);
    return { sent: true };
  }

  const result = await sendOTP(phone, otp, clientToken);

  // Firebase returns a sessionInfo token instead of the client entering a backend-generated OTP.
  // Store sessionInfo in the otp column so verifyOTP can detect and handle it.
  const storedValue = result.sessionInfo || otp;
  await pool.query(
    `INSERT INTO otp_sessions (phone, otp, purpose, expires_at) VALUES ($1, $2, $3, $4)`,
    [phone, storedValue, purpose, expiresAt]
  );

  return { sent: result.sent };
};

const isFirebaseSessionInfo = (stored) => stored && stored.length > 10 && !/^\d{6}$/.test(stored);

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

  let valid = false;

  if (isFirebaseSessionInfo(session.otp)) {
    // Firebase provider — verify code against Firebase REST API
    try {
      const webApiKey = await getSetting('FIREBASE_WEB_API_KEY');
      if (!webApiKey) return false;
      valid = await verifyViaFirebase(session.otp, otp, webApiKey);
    } catch {
      valid = false;
    }
  } else {
    valid = session.otp === otp;
  }

  if (!valid) {
    await pool.query(`UPDATE otp_sessions SET attempts = attempts + 1 WHERE id = $1`, [session.id]);
    return false;
  }

  await pool.query(`UPDATE otp_sessions SET is_used = TRUE WHERE id = $1`, [session.id]);
  return true;
};

module.exports = { createOTPSession, verifyOTP, checkOtpRateLimit };
