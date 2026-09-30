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

// ─── MessageCentral (VerifyNow) ──────────────────────────────────────────────
// Docs: https://www.messagecentral.com/product/verify-now/api-india
// Provider-side verification (like Firebase): send() returns a verificationId to store,
// validateOtp() checks the code against MessageCentral — we never see or hash the code ourselves.
const MC_BASE = 'https://cpaas.messagecentral.com';
let mcTokenCache = { token: null, at: 0, customerId: null };
const MC_TOKEN_TTL_MS = 60 * 60 * 1000; // MessageCentral doesn't publish an exact TTL — re-fetch hourly to be safe

// The dashboard hands out a single long-lived Auth Token (a JWT, valid for years) meant to be used
// as-is — not the short base64 "password" the /authentication/token exchange endpoint expects.
// If the configured key already looks like a JWT, use it directly; only fall back to the exchange
// call for the older-style short base64 key.
const looksLikeJwt = (s) => typeof s === 'string' && s.split('.').length === 3;

const getMessageCentralToken = async (customerId, authKey) => {
  if (looksLikeJwt(authKey)) return authKey;
  if (mcTokenCache.token && mcTokenCache.customerId === customerId && Date.now() - mcTokenCache.at < MC_TOKEN_TTL_MS) {
    return mcTokenCache.token;
  }
  const response = await axios.get(`${MC_BASE}/auth/v1/authentication/token`, {
    params: { customerId, key: authKey, scope: 'NEW', country: '91' },
    headers: { accept: '*/*' },
  });
  if (response.data?.status !== 200 || !response.data?.token) {
    throw new Error(`MessageCentral auth failed: ${JSON.stringify(response.data).slice(0, 200)}`);
  }
  mcTokenCache = { token: response.data.token, at: Date.now(), customerId };
  return mcTokenCache.token;
};

const sendViaMessageCentral = async (phone, customerId, authKey) => {
  const token = await getMessageCentralToken(customerId, authKey);
  // otpLength: our verification UI always shows OTP_LENGTH (6) input boxes — MessageCentral defaults
  // to 4 digits otherwise, which doesn't fit.
  const response = await axios.post(`${MC_BASE}/verification/v3/send`, null, {
    params: { countryCode: '91', flowType: 'SMS', mobileNumber: phone, customerId, otpLength: 6 },
    headers: { authToken: token },
  });
  const data = response.data?.data;
  if (response.data?.responseCode !== 200 || !data?.verificationId) {
    throw new Error(data?.errorMessage || response.data?.message || 'Unknown MessageCentral error');
  }
  console.log('✅ MessageCentral SMS sent');
  return data.verificationId;
};

const verifyViaMessageCentral = async (verificationId, code, customerId, authKey) => {
  const token = await getMessageCentralToken(customerId, authKey);
  const response = await axios.get(`${MC_BASE}/verification/v3/validateOtp`, {
    params: { verificationId, code, flowType: 'SMS' },
    headers: { authToken: token },
  });
  return response.data?.data?.verificationStatus === 'VERIFICATION_COMPLETED';
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
// No SMS provider configured: fine to pretend in development (code is logged), never on production.
const notConfigured = () => ({ sent: process.env.NODE_ENV !== 'production' });

// OTP codes are stored hashed ("h:<sha256>"); Firebase session info is stored as-is.
const hashOtp = (otp) => `h:${crypto.createHash('sha256').update(String(otp)).digest('hex')}`;

const sendOTP = async (phone, otp, clientToken = '') => {
  if (process.env.NODE_ENV !== 'production') {
    console.log(`📱 OTP for ${phone}: ${otp}`);
  }

  const provider = await getSetting('OTP_PROVIDER') || 'firebase';

  try {
    if (provider === 'firebase') {
      const webApiKey = await getSetting('FIREBASE_WEB_API_KEY');
      if (!webApiKey) { console.log('⚠️  FIREBASE_WEB_API_KEY not set'); return notConfigured(); }
      const sessionInfo = await sendViaFirebase(phone, webApiKey, clientToken);
      return { sent: true, sessionInfo };
    }

    if (provider === 'messagecentral') {
      const customerId = await getSetting('MESSAGECENTRAL_CUSTOMER_ID');
      const authKey = await getSetting('MESSAGECENTRAL_AUTH_KEY');
      if (!customerId || !authKey) { console.log('⚠️  MessageCentral credentials not configured'); return notConfigured(); }
      const verificationId = await sendViaMessageCentral(phone, customerId, authKey);
      return { sent: true, verificationId };
    }

    if (provider === 'msg91') {
      const authKey = await getSetting('MSG91_AUTH_KEY');
      const templateId = await getSetting('MSG91_TEMPLATE_ID');
      if (!authKey || !templateId) { console.log('⚠️  MSG91 credentials not configured'); return notConfigured(); }
      await sendViaMSG91(phone, otp, authKey, templateId);
      return { sent: true };
    }

    if (provider === 'fast2sms') {
      const apiKey = await getSetting('FAST2SMS_API_KEY');
      if (!apiKey) { console.log('⚠️  FAST2SMS_API_KEY not configured'); return notConfigured(); }
      await sendViaFast2SMS(phone, otp, apiKey);
      return { sent: true };
    }

    // Default: 2Factor.in
    const apiKey = await getSetting('TWO_FACTOR_API_KEY');
    if (!apiKey || apiKey === 'your_2factor_api_key') {
      console.log('⚠️  2Factor.in API key not configured');
      return notConfigured();
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
      [phone, hashOtp(otp), purpose, expiresAt]
    );
    console.log(`🧪 Test OTP for ${phone}: ${otp}`);
    return { sent: true };
  }

  const result = await sendOTP(phone, otp, clientToken);

  // Firebase/MessageCentral verify the code themselves — we store their session/verification id
  // instead of our own OTP hash, so verifyOTP knows to check with the provider, not compare locally.
  const storedValue = result.sessionInfo || (result.verificationId ? `mc:${result.verificationId}` : null) || hashOtp(otp);
  await pool.query(
    `INSERT INTO otp_sessions (phone, otp, purpose, expires_at) VALUES ($1, $2, $3, $4)`,
    [phone, storedValue, purpose, expiresAt]
  );

  return { sent: result.sent };
};

const isFirebaseSessionInfo = (stored) => stored && stored.length > 10 && !/^\d{6}$/.test(stored) && !stored.startsWith('h:');

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

  if (session.otp.startsWith('mc:')) {
    try {
      const customerId = await getSetting('MESSAGECENTRAL_CUSTOMER_ID');
      const authKey = await getSetting('MESSAGECENTRAL_AUTH_KEY');
      if (!customerId || !authKey) return false;
      valid = await verifyViaMessageCentral(session.otp.slice(3), otp, customerId, authKey);
    } catch {
      valid = false;
    }
  } else if (isFirebaseSessionInfo(session.otp)) {
    // Firebase provider — verify code against Firebase REST API
    try {
      const webApiKey = await getSetting('FIREBASE_WEB_API_KEY');
      if (!webApiKey) return false;
      valid = await verifyViaFirebase(session.otp, otp, webApiKey);
    } catch {
      valid = false;
    }
  } else {
    const expected = Buffer.from(session.otp.startsWith('h:') ? session.otp : hashOtp(session.otp));
    const given = Buffer.from(hashOtp(otp));
    valid = expected.length === given.length && crypto.timingSafeEqual(expected, given);
  }

  if (!valid) {
    await pool.query(`UPDATE otp_sessions SET attempts = attempts + 1 WHERE id = $1`, [session.id]);
    return false;
  }

  await pool.query(`UPDATE otp_sessions SET is_used = TRUE WHERE id = $1`, [session.id]);
  return true;
};

module.exports = { createOTPSession, verifyOTP, checkOtpRateLimit };
