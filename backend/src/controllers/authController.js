const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const pool = require('../db/pool');
const { createOTPSession, verifyOTP, checkOtpRateLimit } = require('../utils/otp');
const { generateTokens, revokeRefreshToken } = require('../utils/jwt');

// POST /auth/send-otp
const sendOtp = async (req, res) => {
  const { phone, purpose = 'login' } = req.body;
  if (!phone || !/^[6-9]\d{9}$/.test(phone)) {
    return res.status(400).json({ success: false, message: 'Invalid phone number' });
  }

  if (purpose === 'signup') {
    const existing = await pool.query('SELECT id FROM users WHERE phone = $1', [phone]);
    if (existing.rows.length) {
      return res.status(409).json({ success: false, message: 'Phone already registered. Please login.' });
    }
  }

  if (purpose === 'login' || purpose === 'forgot_password') {
    const existing = await pool.query('SELECT id FROM users WHERE phone = $1', [phone]);
    if (!existing.rows.length) {
      return res.status(404).json({ success: false, message: 'No account found with this number' });
    }
  }

  const rateLimit = await checkOtpRateLimit(phone);
  if (!rateLimit.allowed) {
    return res.status(429).json({ success: false, message: rateLimit.message });
  }

  await createOTPSession(phone, purpose);
  res.json({ success: true, message: `OTP sent to ${phone}` });
};

// POST /auth/verify-otp  (login via OTP)
const verifyOtpLogin = async (req, res) => {
  const { phone, otp } = req.body;
  if (!phone || !otp) {
    return res.status(400).json({ success: false, message: 'Phone and OTP required' });
  }

  const valid = await verifyOTP(phone, otp, 'login');
  if (!valid) {
    return res.status(400).json({ success: false, message: 'Invalid or expired OTP' });
  }

  const result = await pool.query(
    `UPDATE users SET is_phone_verified = TRUE WHERE phone = $1 RETURNING id, name, email, phone, avatar_url, role`,
    [phone]
  );

  if (!result.rows.length) {
    return res.status(404).json({ success: false, message: 'User not found' });
  }

  const user = result.rows[0];
  const { accessToken, refreshToken } = await generateTokens(user.id);

  res.json({ success: true, message: 'Login successful', data: { user, accessToken, refreshToken } });
};

// POST /auth/signup
const signup = async (req, res) => {
  const { name, phone, email, otp } = req.body;
  if (!name || !phone || !otp) {
    return res.status(400).json({ success: false, message: 'Name, phone and OTP required' });
  }

  const valid = await verifyOTP(phone, otp, 'signup');
  if (!valid) {
    return res.status(400).json({ success: false, message: 'Invalid or expired OTP' });
  }

  const existing = await pool.query('SELECT id FROM users WHERE phone = $1', [phone]);
  if (existing.rows.length) {
    return res.status(409).json({ success: false, message: 'Phone already registered' });
  }

  const result = await pool.query(
    `INSERT INTO users (name, phone, email, is_phone_verified)
     VALUES ($1, $2, $3, TRUE)
     RETURNING id, name, email, phone, avatar_url, role`,
    [name, phone, email || null]
  );

  const user = result.rows[0];
  const { accessToken, refreshToken } = await generateTokens(user.id);

  res.status(201).json({ success: true, message: 'Account created!', data: { user, accessToken, refreshToken } });
};

// POST /auth/login  (email+password or phone+password)
const login = async (req, res) => {
  const { phone, email, password } = req.body;
  if ((!phone && !email) || !password) {
    return res.status(400).json({ success: false, message: 'Credentials required' });
  }

  const query = phone
    ? 'SELECT * FROM users WHERE phone = $1 AND is_active = TRUE'
    : 'SELECT * FROM users WHERE email = $1 AND is_active = TRUE';
  const result = await pool.query(query, [phone || email]);

  if (!result.rows.length) {
    return res.status(401).json({ success: false, message: 'Invalid credentials' });
  }

  const user = result.rows[0];
  if (!user.password_hash) {
    return res.status(400).json({ success: false, message: 'Please use OTP login' });
  }

  const match = await bcrypt.compare(password, user.password_hash);
  if (!match) {
    return res.status(401).json({ success: false, message: 'Invalid credentials' });
  }

  const { accessToken, refreshToken } = await generateTokens(user.id);
  const { password_hash, ...safeUser } = user;

  res.json({ success: true, message: 'Login successful', data: { user: safeUser, accessToken, refreshToken } });
};

// POST /auth/forgot-password  → sends OTP
const forgotPassword = async (req, res) => {
  const { phone } = req.body;
  if (!phone) return res.status(400).json({ success: false, message: 'Phone required' });

  const result = await pool.query('SELECT id FROM users WHERE phone = $1', [phone]);
  if (!result.rows.length) {
    return res.status(404).json({ success: false, message: 'No account with this number' });
  }

  await createOTPSession(phone, 'forgot_password');
  res.json({ success: true, message: 'OTP sent for password reset' });
};

// POST /auth/reset-password
const resetPassword = async (req, res) => {
  const { phone, otp, newPassword } = req.body;
  if (!phone || !otp || !newPassword) {
    return res.status(400).json({ success: false, message: 'All fields required' });
  }
  if (newPassword.length < 6) {
    return res.status(400).json({ success: false, message: 'Password must be at least 6 characters' });
  }

  const valid = await verifyOTP(phone, otp, 'forgot_password');
  if (!valid) {
    return res.status(400).json({ success: false, message: 'Invalid or expired OTP' });
  }

  const hash = await bcrypt.hash(newPassword, 10);
  await pool.query('UPDATE users SET password_hash = $1 WHERE phone = $2', [hash, phone]);

  res.json({ success: true, message: 'Password reset successfully' });
};

// GET /auth/me
const getMe = async (req, res) => {
  res.json({ success: true, data: { user: req.user } });
};

// POST /auth/logout
const logout = async (req, res) => {
  const { refreshToken } = req.body;
  if (refreshToken) await revokeRefreshToken(refreshToken);
  res.json({ success: true, message: 'Logged out successfully' });
};

// POST /auth/refresh-token
const refreshToken = async (req, res) => {
  const { refreshToken: token } = req.body;
  if (!token) return res.status(400).json({ success: false, message: 'Refresh token required' });

  try {
    const decoded = jwt.verify(token, process.env.JWT_REFRESH_SECRET);
    const result = await pool.query(
      'SELECT id FROM refresh_tokens WHERE token = $1 AND expires_at > NOW()',
      [token]
    );
    if (!result.rows.length) {
      return res.status(401).json({ success: false, message: 'Invalid refresh token' });
    }
    await revokeRefreshToken(token);
    const { accessToken, refreshToken: newRefresh } = await generateTokens(decoded.id);
    res.json({ success: true, data: { accessToken, refreshToken: newRefresh } });
  } catch {
    res.status(401).json({ success: false, message: 'Invalid refresh token' });
  }
};

// POST /auth/fcm-token
const saveFcmToken = async (req, res) => {
  const { token, platform = 'android' } = req.body;
  if (!token) return res.status(400).json({ success: false, message: 'FCM token required' });

  await pool.query(
    `INSERT INTO fcm_tokens (user_id, token, platform)
     VALUES ($1, $2, $3)
     ON CONFLICT (user_id, token) DO NOTHING`,
    [req.user.id, token, platform]
  );
  res.json({ success: true, message: 'FCM token saved' });
};

module.exports = { sendOtp, verifyOtpLogin, signup, login, forgotPassword, resetPassword, getMe, logout, refreshToken, saveFcmToken };
