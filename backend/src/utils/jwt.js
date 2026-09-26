const crypto = require('crypto');
const jwt = require('jsonwebtoken');
const pool = require('../db/pool');

// Store staff (admin / support) accounts get short sessions, enforced on the server:
// 1-hour access tokens and a 12-hour refresh window (they sign in again at least twice a day).
const STAFF_ROLES = ['admin', 'support_staff'];
const STAFF_ACCESS_MAX_SEC = 60 * 60;
const STAFF_REFRESH_MAX_SEC = 12 * 60 * 60;
const isStaff = (role) => STAFF_ROLES.includes(role);

// Refresh tokens are stored hashed (a database leak doesn't hand out sessions).
const hashToken = (token) => crypto.createHash('sha256').update(String(token)).digest('hex');

const generateTokens = async (userId) => {
  const role = (await pool.query('SELECT role FROM users WHERE id = $1', [userId])).rows[0]?.role;
  const staff = isStaff(role);
  const accessToken = jwt.sign({ id: userId }, process.env.JWT_SECRET, {
    expiresIn: staff ? STAFF_ACCESS_MAX_SEC : (process.env.JWT_EXPIRES_IN || '7d'),
  });
  const refreshSec = staff ? STAFF_REFRESH_MAX_SEC : 30 * 24 * 60 * 60;
  const refreshToken = jwt.sign({ id: userId }, process.env.JWT_REFRESH_SECRET, {
    expiresIn: staff ? STAFF_REFRESH_MAX_SEC : (process.env.JWT_REFRESH_EXPIRES_IN || '30d'),
  });

  await pool.query(
    `INSERT INTO refresh_tokens (user_id, token, expires_at) VALUES ($1, $2, $3)`,
    [userId, hashToken(refreshToken), new Date(Date.now() + refreshSec * 1000)]
  );

  return { accessToken, refreshToken };
};

// Accepts tokens stored before hashing was introduced (plain) as well as hashed ones.
const findRefreshToken = async (token) =>
  (await pool.query(
    'SELECT id, user_id FROM refresh_tokens WHERE token = ANY($1::text[]) AND expires_at > NOW()',
    [[hashToken(token), token]]
  )).rows[0] || null;

const revokeRefreshToken = async (token) => {
  await pool.query(`DELETE FROM refresh_tokens WHERE token = ANY($1::text[])`, [[hashToken(token), token]]);
};

module.exports = { generateTokens, revokeRefreshToken, findRefreshToken, isStaff, STAFF_ACCESS_MAX_SEC, STAFF_REFRESH_MAX_SEC };
