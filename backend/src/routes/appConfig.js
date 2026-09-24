const router = require('express').Router();
const pool = require('../db/pool');

// GET /api/app-config — public, polled by the app on startup
router.get('/', async (req, res, next) => {
  try {
    const result = await pool.query(
      `SELECT key, value FROM store_settings
       WHERE key IN ('maintenance_mode', 'maintenance_message', 'force_update_enabled', 'min_app_version', 'force_update_message',
                     'free_shipping_enabled', 'free_shipping_threshold', 'standard_shipping_fee', 'gst_rate')`
    );
    const data = {};
    result.rows.forEach((row) => { data[row.key] = row.value; });

    res.json({
      success: true,
      data: {
        maintenance_mode: data.maintenance_mode === 'true',
        maintenance_message: data.maintenance_message || "We're making some improvements to serve you better. We'll be back soon!",
        force_update_enabled: data.force_update_enabled === 'true',
        min_app_version: data.min_app_version || '1.0.0',
        force_update_message: data.force_update_message || 'A new version of the app is available. Please update to continue.',
        free_shipping_enabled: data.free_shipping_enabled !== 'false',
        free_shipping_threshold: parseFloat(data.free_shipping_threshold ?? 499),
        standard_shipping_fee: parseFloat(data.standard_shipping_fee ?? 49),
        gst_rate: parseFloat(data.gst_rate ?? 18),
      },
    });
  } catch (err) { next(err); }
});

module.exports = router;
