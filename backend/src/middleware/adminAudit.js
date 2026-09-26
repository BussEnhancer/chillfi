const pool = require('../db/pool');

// Values that are safe and useful to keep in the history; everything else is recorded by field name only.
const SAFE_VALUES = ['status', 'role', 'is_active', 'key', 'refund_status', 'code', 'type', 'name'];

// Records every successful change made through /api/admin (after the response is sent — never slows or blocks it).
const adminAudit = (req, res, next) => {
  if (req.method === 'GET' || req.method === 'HEAD' || req.method === 'OPTIONS') return next();
  res.on('finish', () => {
    if (res.statusCode >= 400 || !req.user) return;
    const body = req.body && typeof req.body === 'object' ? req.body : {};
    const secretCall = req.path.startsWith('/credentials');
    const details = { fields: Object.keys(body).slice(0, 40) };
    for (const k of SAFE_VALUES) {
      if (body[k] !== undefined && !(secretCall && k !== 'key')) details[k] = String(body[k]).slice(0, 80);
    }
    pool.query(
      'INSERT INTO admin_audit_log (actor_id, actor_name, method, path, details, ip) VALUES ($1,$2,$3,$4,$5,$6)',
      [req.user.id, req.user.name || null, req.method, req.originalUrl.split('?')[0].slice(0, 200), JSON.stringify(details), req.ip]
    ).catch((e) => console.error('[audit] not recorded:', e.message));
  });
  next();
};

module.exports = { adminAudit };
