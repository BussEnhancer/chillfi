const pool = require('../db/pool');

// Looks up the most specific active shipping_rules row matching the pincode
// (longest matching prefix wins), falling back to the flat-fee store_settings.
const getShippingRule = async (pincode) => {
  if (!pincode) return null;
  const rule = await pool.query(
    `SELECT * FROM shipping_rules WHERE is_active = TRUE AND $1 LIKE pincode_prefix || '%'
     ORDER BY LENGTH(pincode_prefix) DESC LIMIT 1`,
    [String(pincode)]
  );
  return rule.rows[0] || null;
};

// Courier serviceability combined with the admin shipping rule for the pincode:
// a rule with cod_available=false disables COD even when the courier allows it; estimated_days → eta_days.
const checkoutServiceability = async (pincode) => {
  const { pincodeServiceability } = require('./delhivery');
  const svc = await pincodeServiceability(pincode);
  if (svc.serviceable === false) return svc;
  const [r, codSetting] = await Promise.all([
    getShippingRule(svc.pincode || pincode),
    pool.query(`SELECT value FROM store_settings WHERE key = 'cod_enabled'`),
  ]);
  // Store-wide switch (Admin → Settings → Shipping → COD Available) or a pincode rule can turn COD off.
  const codBlocked = codSetting.rows[0]?.value === 'false' || r?.cod_available === false;
  return { ...svc, cod: codBlocked ? false : svc.cod, eta_days: r?.estimated_days ?? null, cod_blocked: codBlocked };
};

const getShippingFee = async (pincode, subtotal) => {
  if (pincode) {
    const r = await getShippingRule(pincode);
    if (r) {
      if (r.free_above != null && subtotal >= parseFloat(r.free_above)) return 0;
      return parseFloat(r.fee);
    }
  }

  const settings = await pool.query(
    `SELECT key, value FROM store_settings WHERE key IN ('free_shipping_threshold', 'standard_shipping_fee', 'free_shipping_enabled')`
  );
  const map = {};
  settings.rows.forEach((row) => { map[row.key] = row.value; });
  const threshold = parseFloat(map.free_shipping_threshold ?? 499);
  const fee = parseFloat(map.standard_shipping_fee ?? 49);
  // Admin can switch free shipping off entirely (Settings → free_shipping_enabled).
  const freeEnabled = map.free_shipping_enabled !== 'false';
  return freeEnabled && subtotal >= threshold ? 0 : fee;
};

module.exports = { getShippingFee, getShippingRule, checkoutServiceability };
