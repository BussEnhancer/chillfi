const jwt = require('jsonwebtoken');
const pool = require('../db/pool');

const authenticate = async (req, res, next) => {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, message: 'No token provided' });
  }
  const token = header.split(' ')[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const result = await pool.query('SELECT id, name, email, phone, role, avatar_url, is_active FROM users WHERE id = $1', [decoded.id]);
    if (!result.rows.length || !result.rows[0].is_active) {
      return res.status(401).json({ success: false, message: 'User not found or inactive' });
    }
    req.user = result.rows[0];
    next();
  } catch {
    return res.status(401).json({ success: false, message: 'Invalid or expired token' });
  }
};

// Attaches req.user when a valid token is present, but never rejects the request —
// used by routes that personalize for logged-in users while staying open to guests.
const optionalAuthenticate = async (req, res, next) => {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) return next();

  const token = header.split(' ')[1];
  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const result = await pool.query('SELECT id, name, email, phone, role, avatar_url, is_active FROM users WHERE id = $1', [decoded.id]);
    if (result.rows.length && result.rows[0].is_active) {
      req.user = result.rows[0];
    }
  } catch {
    // invalid/expired token — proceed as guest rather than failing
  }
  next();
};

const adminOnly = (req, res, next) => {
  if (req.user?.role !== 'admin') {
    return res.status(403).json({ success: false, message: 'Admin access required' });
  }
  next();
};

const staffOrAdmin = (req, res, next) => {
  if (!['admin', 'support_staff'].includes(req.user?.role)) {
    return res.status(403).json({ success: false, message: 'Admin or support staff access required' });
  }
  next();
};

module.exports = { authenticate, optionalAuthenticate, adminOnly, staffOrAdmin };
