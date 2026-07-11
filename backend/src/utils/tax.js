const pool = require('../db/pool');

// GST is applied on the taxable amount (subtotal minus discount), at the rate
// configured in store_settings.gst_rate (percentage, defaults to 18%).
const getGstAmount = async (taxableAmount) => {
  const settings = await pool.query(`SELECT value FROM store_settings WHERE key = 'gst_rate'`);
  const rate = parseFloat(settings.rows[0]?.value ?? 18);
  return parseFloat(((taxableAmount * rate) / 100).toFixed(2));
};

module.exports = { getGstAmount };
