const crypto = require('crypto');
const pool = require('../db/pool');

const settingsCache = new Map();
const CACHE_TTL = 30000; // 30 seconds

// ── Encryption at rest for secret credentials stored via Admin → Settings ──
// Values are stored as "enc:v1:<iv>:<tag>:<ciphertext>" (AES-256-GCM, base64 parts).
// Key: SETTINGS_ENCRYPTION_KEY if set, otherwise derived from JWT_SECRET so existing
// deployments work without a new env var. Plaintext legacy values still read fine.
const ENC_PREFIX = 'enc:v1:';

const getKey = () => {
  const material = process.env.SETTINGS_ENCRYPTION_KEY || process.env.JWT_SECRET;
  if (!material) return null;
  return crypto.createHash('sha256').update(`chillfi-settings:${material}`).digest();
};

const encryptValue = (plain) => {
  const key = getKey();
  if (!key || plain == null || plain === '') return plain;
  const iv = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);
  const enc = Buffer.concat([cipher.update(String(plain), 'utf8'), cipher.final()]);
  return `${ENC_PREFIX}${iv.toString('base64')}:${cipher.getAuthTag().toString('base64')}:${enc.toString('base64')}`;
};

const decryptValue = (stored) => {
  if (typeof stored !== 'string' || !stored.startsWith(ENC_PREFIX)) return stored;
  const key = getKey();
  if (!key) return null;
  try {
    const [iv, tag, data] = stored.slice(ENC_PREFIX.length).split(':');
    const decipher = crypto.createDecipheriv('aes-256-gcm', key, Buffer.from(iv, 'base64'));
    decipher.setAuthTag(Buffer.from(tag, 'base64'));
    return Buffer.concat([decipher.update(Buffer.from(data, 'base64')), decipher.final()]).toString('utf8');
  } catch {
    console.error('[settings] failed to decrypt a stored credential (encryption key changed?)');
    return null;
  }
};

const getSetting = async (key) => {
  const cached = settingsCache.get(key);
  if (cached && Date.now() - cached.ts < CACHE_TTL) return cached.value;

  try {
    const result = await pool.query('SELECT value FROM store_settings WHERE key = $1', [key]);
    const value = decryptValue(result.rows[0]?.value) || process.env[key] || null;
    settingsCache.set(key, { value, ts: Date.now() });
    return value;
  } catch {
    return process.env[key] || null;
  }
};

// Upsert a setting; secret values are encrypted before hitting the DB.
const setSetting = async (key, value, { secret = false } = {}) => {
  const stored = value == null || value === '' ? null : secret ? encryptValue(value) : String(value);
  await pool.query(
    `INSERT INTO store_settings (key, value) VALUES ($1, $2)
     ON CONFLICT (key) DO UPDATE SET value = EXCLUDED.value, updated_at = NOW()`,
    [key, stored]
  );
  invalidateCache(key);
};

const invalidateCache = (key) => settingsCache.delete(key);

module.exports = { getSetting, setSetting, invalidateCache, encryptValue, decryptValue };
