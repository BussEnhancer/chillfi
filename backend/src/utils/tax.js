const pool = require('../db/pool');

// Prices are GST-INCLUSIVE (owner decision 2026-09-25): the displayed price is what the customer pays.
// This returns the GST contained in an inclusive amount (for the breakdown / invoices), at
// store_settings.gst_rate (percentage, default 18%):  gst = amount × rate / (100 + rate).
const getIncludedGst = async (inclusiveAmount) => {
  const settings = await pool.query(`SELECT value FROM store_settings WHERE key = 'gst_rate'`);
  const rate = parseFloat(settings.rows[0]?.value ?? 18);
  return parseFloat(((inclusiveAmount * rate) / (100 + rate)).toFixed(2));
};

module.exports = { getIncludedGst };
