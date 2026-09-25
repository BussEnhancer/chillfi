const crypto = require('crypto');
const pool = require('../db/pool');

const settingsCache = new Map();
const CACHE_TTL = 30000; // 30 seconds

// ── Encryption at rest for secret credentials stored via Admin → Settings ──
// Values are stored as "enc:v1:<iv>:<tag>:<ciphertext>" (AES-256-GCM, base64 parts).
// Key: SETTINGS_ENCRYPTION_KEY if set, otherwise derived from JWT_SECRET so existing
// deployments work without a new env var. Plaintext legacy values still read fine.
const ENC_PREFIX = 'enc:v1:';

const deriveKey = (material) => crypto.createHash('sha256').update(`chillfi-settings:${material}`).digest();
const getKey = () => {
  const material = process.env.SETTINGS_ENCRYPTION_KEY || process.env.JWT_SECRET;
  return material ? deriveKey(material) : null;
};
// Keys to try when reading: the current key, then the legacy JWT_SECRET-derived key (values stored
// before SETTINGS_ENCRYPTION_KEY was introduced). reencryptLegacySettings() moves them to the new key.
const readKeys = () => [process.env.SETTINGS_ENCRYPTION_KEY, process.env.JWT_SECRET].filter(Boolean).map(deriveKey);

const encryptValue = (plain) => {
  const key = getKey();
  if (!key || plain == null || plain === '') return plain;
  const iv = crypto.randomBytes(12);
  const cipher = crypto.createCipheriv('aes-256-gcm', key, iv);
  const enc = Buffer.concat([cipher.update(String(plain), 'utf8'), cipher.final()]);
  return `${ENC_PREFIX}${iv.toString('base64')}:${cipher.getAuthTag().toString('base64')}:${enc.toString('base64')}`;
};

const decryptWith = (key, stored) => {
  const [iv, tag, data] = stored.slice(ENC_PREFIX.length).split(':');
  const decipher = crypto.createDecipheriv('aes-256-gcm', key, Buffer.from(iv, 'base64'));
  decipher.setAuthTag(Buffer.from(tag, 'base64'));
  return Buffer.concat([decipher.update(Buffer.from(data, 'base64')), decipher.final()]).toString('utf8');
};

const decryptValue = (stored) => {
  if (typeof stored !== 'string' || !stored.startsWith(ENC_PREFIX)) return stored;
  for (const key of readKeys()) {
    try { return decryptWith(key, stored); } catch { /* try the next key */ }
  }
  console.error('[settings] failed to decrypt a stored credential (encryption key changed?)');
  return null;
};

// On start-up: credentials still encrypted with the legacy key are re-encrypted with SETTINGS_ENCRYPTION_KEY.
const reencryptLegacySettings = async () => {
  if (!process.env.SETTINGS_ENCRYPTION_KEY) return 0;
  const current = getKey();
  const { rows } = await pool.query(`SELECT key, value FROM store_settings WHERE value LIKE $1`, [`${ENC_PREFIX}%`]);
  let moved = 0;
  for (const r of rows) {
    try { decryptWith(current, r.value); continue; } catch { /* not on the current key */ }
    const plain = decryptValue(r.value);
    if (plain == null) continue;
    await pool.query('UPDATE store_settings SET value = $1, updated_at = NOW() WHERE key = $2', [encryptValue(plain), r.key]);
    moved++;
  }
  if (moved) console.log(`[settings] re-encrypted ${moved} credential(s) with SETTINGS_ENCRYPTION_KEY`);
  return moved;
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

module.exports = { getSetting, setSetting, invalidateCache, encryptValue, decryptValue, reencryptLegacySettings };
