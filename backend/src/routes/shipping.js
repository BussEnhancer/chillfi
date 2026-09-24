const router = require('express').Router();
const crypto = require('crypto');
const { getSetting, setSetting } = require('../utils/settings');
const rateLimit = require('express-rate-limit');
const { normalizeShipment } = require('../utils/delhivery');
const { checkoutServiceability } = require('../utils/shipping');
const { applyCourierUpdate } = require('../services/shipmentService');

const safeEqual = (a, b) => {
  const ba = Buffer.from(String(a)); const bb = Buffer.from(String(b));
  return ba.length === bb.length && crypto.timingSafeEqual(ba, bb);
};

// Delhivery lets the client specify the auth header it sends with scan pushes.
// Configure Delhivery to send "Authorization: Bearer <DELHIVERY_WEBHOOK_SECRET>"
// (x-webhook-token header or ?token= are accepted as fallbacks).
const extractToken = (req) => {
  const auth = req.headers.authorization || '';
  const m = auth.match(/^(?:Bearer|Token)\s+(.+)$/i);
  return (m && m[1]) || req.headers['x-webhook-token'] || req.query.token || null;
};

// Accepts documented shape { Shipment: {...} } plus array / ShipmentData wrappers.
const extractShipments = (body) => {
  if (!body || typeof body !== 'object') return [];
  const list = Array.isArray(body) ? body : body.ShipmentData ? body.ShipmentData : [body];
  return list.map((x) => x?.Shipment || null).filter((s) => s && s.AWB && s.Status);
};

// POST /api/shipping/delhivery/webhook
router.post('/delhivery/webhook', async (req, res) => {
  const secret = await getSetting('DELHIVERY_WEBHOOK_SECRET');
  if (!secret) {
    console.warn('[shipping] webhook rejected: DELHIVERY_WEBHOOK_SECRET not configured');
    return res.status(503).json({ success: false, message: 'Webhook not configured' });
  }
  const token = extractToken(req);
  if (!token || !safeEqual(token, secret)) {
    console.warn(`[shipping] webhook rejected: bad token from ${req.ip}`);
    return res.status(401).json({ success: false, message: 'Unauthorized' });
  }

  const shipments = extractShipments(req.body);
  if (!shipments.length) {
    console.warn('[shipping] webhook invalid payload (no Shipment.AWB/Status)');
    return res.status(400).json({ success: false, message: 'Invalid payload' });
  }

  const results = [];
  for (const s of shipments) {
    try {
      const u = normalizeShipment(s);
      const r = await applyCourierUpdate({ ...u, awb: u.waybill }, { source: 'webhook', raw: s });
      results.push({ awb: u.waybill, ...r });
    } catch (err) {
      console.error(`[shipping] webhook processing error awb=${s.AWB}: ${err.message}`);
      // 500 so Delhivery retries; processing is idempotent.
      return res.status(500).json({ success: false, message: 'Processing error' });
    }
  }
  setSetting('DELHIVERY_WEBHOOK_LAST_RECEIVED', new Date().toISOString()).catch(() => {});
  res.json({ success: true, results });
});

// GET /api/shipping/pincode/:pin — public serviceability check used by checkout (app + website).
// Own limiter because /api/shipping/* is excluded from the global limiter (webhook traffic).
const pinLimiter = rateLimit({ windowMs: 60 * 1000, max: 30, standardHeaders: true, legacyHeaders: false,
  message: { success: false, message: 'Too many pincode checks. Please wait a minute and try again.' } });
router.get('/pincode/:pin', pinLimiter, async (req, res) => {
  const r = await checkoutServiceability(req.params.pin);
  res.json({ success: true, data: r });
});

module.exports = router;
