const pool = require('../db/pool');

// Looks up the most specific active shipping_rules row matching the pincode
// (longest matching prefix wins), falling back to the flat-fee store_settings.
const getShippingFee = async (pincode, subtotal) => {
  if (pincode) {
    const rule = await pool.query(
      `SELECT * FROM shipping_rules WHERE is_active = TRUE AND $1 LIKE pincode_prefix || '%'
       ORDER BY LENGTH(pincode_prefix) DESC LIMIT 1`,
      [pincode]
    );
    if (rule.rows.length) {
      const r = rule.rows[0];
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

module.exports = { getShippingFee };
