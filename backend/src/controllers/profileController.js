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
    const { name, email, avatar_url } = req.body;
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

    const result = await uploadToCloudinary(req.file.buffer, 'chillfi/avatars');
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

module.exports = {
  getProfile, updateProfile, uploadAvatar, getMyReviews, getNotifications, getUnreadNotificationCount,
  getNotificationPreferences, updateNotificationPreferences,
};
