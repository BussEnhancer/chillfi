/**
 * PhonePe PG (v1 "pay page" / salt-key API) configuration.
 *
 * All values come from Admin → Settings → API Keys (encrypted in store_settings) with
 * process.env as fallback, so switching UAT → PRODUCTION is a config change only:
 *   PHONEPE_ENV          'UAT' | 'PRODUCTION'
 *   PHONEPE_MERCHANT_ID, PHONEPE_SALT_KEY, PHONEPE_SALT_INDEX
 *
 * Backward compatibility: if PHONEPE_ENV is not set anywhere, the environment is inferred
 * from the legacy PHONEPE_BASE_URL env var (sandbox/preprod URL → UAT, otherwise PRODUCTION).
 */
const crypto = require('crypto');
const { getSetting } = require('./settings');

const BASE_URLS = {
  UAT: 'https://api-preprod.phonepe.com/apis/pg-sandbox',
  PRODUCTION: 'https://api.phonepe.com/apis/hermes',
};

const getEnv = async () => {
  const explicit = (await getSetting('PHONEPE_ENV')) || '';
  if (/^prod/i.test(explicit)) return 'PRODUCTION';
  if (explicit) return 'UAT';
  const legacyUrl = process.env.PHONEPE_BASE_URL || '';
  if (legacyUrl && !/preprod|sandbox|uat/i.test(legacyUrl)) return 'PRODUCTION';
  return 'UAT';
};

const getConfig = async () => {
  const env = await getEnv();
  return {
    env,
    baseUrl: BASE_URLS[env],
    merchantId: await getSetting('PHONEPE_MERCHANT_ID'),
    saltKey: await getSetting('PHONEPE_SALT_KEY'),
    saltIndex: (await getSetting('PHONEPE_SALT_INDEX')) || '1',
  };
};

const configProblems = (cfg) =>
  ['merchantId', 'saltKey'].filter((k) => !cfg[k] || /^your/i.test(cfg[k]))
    .map((k) => ({ merchantId: 'PHONEPE_MERCHANT_ID', saltKey: 'PHONEPE_SALT_KEY' }[k]));

// X-VERIFY = SHA256(payload + saltKey) + "###" + saltIndex
const xVerify = (cfg, payload) =>
  crypto.createHash('sha256').update(payload + cfg.saltKey).digest('hex') + `###${cfg.saltIndex}`;

module.exports = { getConfig, getEnv, configProblems, xVerify, BASE_URLS };
