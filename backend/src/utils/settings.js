const pool = require('../db/pool');

const settingsCache = new Map();
const CACHE_TTL = 30000; // 30 seconds

const getSetting = async (key) => {
  const cached = settingsCache.get(key);
  if (cached && Date.now() - cached.ts < CACHE_TTL) return cached.value;

  try {
    const result = await pool.query('SELECT value FROM store_settings WHERE key = $1', [key]);
    const value = result.rows[0]?.value || process.env[key] || null;
    settingsCache.set(key, { value, ts: Date.now() });
    return value;
  } catch {
    return process.env[key] || null;
  }
};

const invalidateCache = (key) => settingsCache.delete(key);

module.exports = { getSetting, invalidateCache };
