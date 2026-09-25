const pool = require('../db/pool');
const { uploadToCloudinary } = require('../middleware/upload');

const getProfile = async (req, res, next) => {
  try {
    const { id: userId } = req.user;
    const result = await pool.query(
      'SELECT id, name, email, phone, avatar_url, role, created_at FROM users WHERE id=$1',
      [userId]
    );
    if (!result.rows.length) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, data: result.rows[0] });
  } catch (err) { next(err); }
};

const updateProfile = async (req, res, next) => {
  try {
    const { id: userId } = req.user;
    const { avatar_url } = req.body;
    const name = typeof req.body.name === 'string' ? req.body.name.trim() : req.body.name;
    const email = typeof req.body.email === 'string' ? req.body.email.trim().toLowerCase() : req.body.email;
    if (name !== undefined && name !== null && name.length < 2) {
      return res.status(400).json({ success: false, message: 'Please enter your full name (at least 2 characters).' });
    }
    if (email) {
      if (!/^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/.test(email)) {
        return res.status(400).json({ success: false, message: 'Please enter a valid email address.' });
      }
      const taken = await pool.query('SELECT 1 FROM users WHERE LOWER(email) = $1 AND id <> $2', [email, userId]);
      if (taken.rows.length) {
        return res.status(409).json({ success: false, message: 'This email is already used by another account.' });
      }
    }
    const result = await pool.query(
      `UPDATE users SET name=COALESCE($1,name), email=COALESCE($2,email),
       avatar_url=COALESCE($3,avatar_url), updated_at=NOW()
       WHERE id=$4 RETURNING id, name, email, phone, avatar_url, role`,
      [name || null, email || null, avatar_url || null, userId]
    );
    res.json({ success: true, message: 'Profile updated', data: result.rows[0] });
  } catch (err) { next(err); }
};

const uploadAvatar = async (req, res, next) => {
  try {
    const { id: userId } = req.user;
    if (!req.file) return res.status(400).json({ success: false, message: 'No file uploaded' });

    let result;
    try {
      result = await uploadToCloudinary(req.file.buffer, 'chillfi/avatars');
    } catch (e) {
      // Upload-service problems are for the admin (logged); customers get a plain message.
      if (e.status === 503) {
        console.warn(`[profile] avatar upload unavailable: ${e.message}`);
        return res.status(503).json({ success: false, message: "Photo upload isn't available right now. Please try again later." });
      }
      throw e;
    }
    const updated = await pool.query(
      `UPDATE users SET avatar_url=$1, updated_at=NOW() WHERE id=$2 RETURNING id, name, email, phone, avatar_url, role`,
      [result.secure_url, userId]
    );
    res.json({ success: true, message: 'Avatar updated', data: updated.rows[0] });
  } catch (err) { next(err); }
};

const getMyReviews = async (req, res, next) => {
  try {
    const { id: userId } = req.user;
    const { page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;
    const result = await pool.query(`
      SELECT r.id, r.rating, r.title, r.body, r.created_at,
             p.id AS product_id, p.name AS product_name,
             pi.url AS product_image
      FROM reviews r
      JOIN products p ON p.id = r.product_id
      LEFT JOIN LATERAL (
        SELECT url FROM product_images WHERE product_id = p.id ORDER BY sort_order LIMIT 1
      ) pi ON true
      WHERE r.user_id=$1
      ORDER BY r.created_at DESC
      LIMIT $2 OFFSET $3
    `, [userId, limit, offset]);
    res.json({ success: true, data: result.rows });
  } catch (err) { next(err); }
};

const getNotifications = async (req, res, next) => {
  try {
    const { id: userId } = req.user;
    const { page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;
    const result = await pool.query(
      `SELECT * FROM notifications WHERE user_id=$1 ORDER BY created_at DESC LIMIT $2 OFFSET $3`,
      [userId, limit, offset]
    );
    // Mark all as read
    await pool.query('UPDATE notifications SET is_read=TRUE WHERE user_id=$1 AND is_read=FALSE', [userId]);
    res.json({ success: true, data: result.rows });
  } catch (err) { next(err); }
};

const getUnreadNotificationCount = async (req, res, next) => {
  try {
    const { id: userId } = req.user;
    const result = await pool.query('SELECT COUNT(*) FROM notifications WHERE user_id=$1 AND is_read=FALSE', [userId]);
    res.json({ success: true, data: { count: parseInt(result.rows[0].count) } });
  } catch (err) { next(err); }
};

const getNotificationPreferences = async (req, res, next) => {
  try {
    const { id: userId } = req.user;
    const result = await pool.query('SELECT notification_preferences FROM users WHERE id=$1', [userId]);
    if (!result.rows.length) return res.status(404).json({ success: false, message: 'User not found' });
    res.json({ success: true, data: result.rows[0].notification_preferences || {} });
  } catch (err) { next(err); }
};

const updateNotificationPreferences = async (req, res, next) => {
  try {
    const { id: userId } = req.user;
    const result = await pool.query(
      `UPDATE users SET notification_preferences=notification_preferences || $1::jsonb, updated_at=NOW() WHERE id=$2 RETURNING notification_preferences`,
      [JSON.stringify(req.body || {}), userId]
    );
    res.json({ success: true, message: 'Preferences updated', data: result.rows[0].notification_preferences });
  } catch (err) { next(err); }
};

// Removes a customer and their personal data; orders are kept (anonymised) for tax records.
const purgeUser = async (userId) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    for (const table of ['fcm_tokens', 'refresh_tokens', 'notifications', 'wishlist', 'recently_viewed', 'cart', 'reviews', 'addresses', 'coupon_usage']) {
      await client.query(`DELETE FROM ${table} WHERE user_id = $1`, [userId]);
    }
    await client.query(
      `UPDATE orders SET user_id = NULL, notes = COALESCE(notes, '') || ' [account deleted]' WHERE user_id = $1`,
      [userId]
    );
    await client.query('DELETE FROM users WHERE id = $1', [userId]);
    await client.query('COMMIT');
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally {
    client.release();
  }
};

const STAFF_ROLES = ['admin', 'super_admin', 'support_staff', 'staff'];
const STAFF_MESSAGE = "Store staff accounts can't be deleted here. Ask another admin to remove the account.";

// DELETE /api/profile/account — signed-in customer deletes their own account (app + website)
const deleteAccount = async (req, res, next) => {
  try {
    const { id: userId, role } = req.user;
    if (STAFF_ROLES.includes(role)) return res.status(403).json({ success: false, message: STAFF_MESSAGE });
    await purgeUser(userId);
    res.json({ success: true, message: 'Account deleted successfully' });
  } catch (err) { next(err); }
};

// POST /api/profile/request-delete — public deletion page (no sign-in).
// Preferred: { idToken } from Firebase phone sign-in (same as login). Legacy: { phone, otp } from /auth/send-otp.
const requestDeleteByPhone = async (req, res, next) => {
  try {
    const { idToken, otp } = req.body || {};
    let phone = req.body?.phone;
    if (idToken) {
      const { getFirebaseApp } = require('../utils/firebase');
      const fbApp = getFirebaseApp();
      if (!fbApp) return res.status(503).json({ success: false, message: 'Phone verification is temporarily unavailable. Please try again later.' });
      const { getAuth } = require('firebase-admin/auth');
      let decoded;
      try { decoded = await getAuth(fbApp).verifyIdToken(idToken); }
      catch { return res.status(401).json({ success: false, message: 'Your verification expired. Please verify your number again.' }); }
      if (!decoded.phone_number) return res.status(400).json({ success: false, message: 'No phone number in the verification' });
      phone = decoded.phone_number.replace(/^\+91/, '');
    } else {
      if (!phone || !otp) return res.status(400).json({ success: false, message: 'Phone and OTP required' });
      const { verifyOTP } = require('../utils/otp');
      const valid = await verifyOTP(phone, otp, 'login');
      if (!valid) return res.status(400).json({ success: false, message: 'Invalid or expired OTP' });
    }

    const userResult = await pool.query('SELECT id, role FROM users WHERE phone = $1', [phone]);
    if (!userResult.rows.length) return res.status(404).json({ success: false, message: 'No account found with this number' });
    if (STAFF_ROLES.includes(userResult.rows[0].role)) return res.status(403).json({ success: false, message: STAFF_MESSAGE });

    await purgeUser(userResult.rows[0].id);
    res.json({ success: true, message: 'Account deleted successfully' });
  } catch (err) { next(err); }
};

module.exports = {
  getProfile, updateProfile, uploadAvatar, getMyReviews, getNotifications, getUnreadNotificationCount,
  getNotificationPreferences, updateNotificationPreferences,
  deleteAccount, requestDeleteByPhone,
};
