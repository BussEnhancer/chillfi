/**
 * LOCAL TEST ONLY — minimal simulator of the Delhivery B2C Express API, built from the
 * documented request/response formats (delhivery-express-api-doc.readme.io).
 * Lets the full ChillFi shipping lifecycle be exercised without a staging token.
 *
 * Usage:  node scripts/delhivery-sim.js
 *   env: SIM_PORT (5099), SIM_TOKEN, SIM_PICKUP, SIM_WEBHOOK_URL, SIM_WEBHOOK_SECRET
 * Point ChillFi at it with DELHIVERY_STAGING_BASE_URL=http://localhost:5099 (honoured in staging only).
 *
 * Test controls:
 *   POST /__sim/advance  {waybill, status_type, status, instructions?, location?, time?, push?:true}
 *   POST /__sim/push-raw {body, token?}      — send an arbitrary webhook body
 *   POST /__sim/fail-next {mode: 'timeout'|'500'|'accept-then-timeout', times?:1}
 *   POST /__sim/config {webhook_secret}
 *   GET  /__sim/packages
 */
const express = require('express');
const axios = require('axios');

const PORT = process.env.SIM_PORT || 5099;
const TOKEN = process.env.SIM_TOKEN || 'sim-local-token';
const PICKUP = process.env.SIM_PICKUP || 'india';
const WEBHOOK_URL = process.env.SIM_WEBHOOK_URL || 'http://localhost:5000/api/shipping/delhivery/webhook';
let WEBHOOK_SECRET = process.env.SIM_WEBHOOK_SECRET || '';

const app = express();
app.use(express.urlencoded({ extended: true, limit: '2mb' }));
app.use(express.json());

const packages = new Map(); // waybill → pkg
let failNext = { mode: null, times: 0 };
const counters = { create: 0, track: 0, cancel: 0 };

const istNow = () => new Date(Date.now() + 5.5 * 3600e3).toISOString().slice(0, 19);
const auth = (req, res, next) => {
  if ((req.headers.authorization || '') !== `Token ${TOKEN}`) return res.status(401).json({ detail: 'Invalid token' });
  next();
};
const takeFailure = () => {
  if (failNext.times > 0) { failNext.times -= 1; const m = failNext.mode; if (!failNext.times) failNext.mode = null; return m; }
  return null;
};

app.get('/c/api/pin-codes/json/', auth, (req, res) => {
  const pin = String(req.query.filter_codes || '');
  if (!/^\d{6}$/.test(pin) || pin.startsWith('99')) return res.json({ delivery_codes: [] });
  res.json({ delivery_codes: [{ postal_code: { pin: Number(pin), cod: 'Y', pre_paid: 'Y', pickup: 'Y', cash: 'Y', district: 'Sim District', state_code: 'SIM' } }] });
});

app.post('/api/cmu/create.json', auth, async (req, res) => {
  counters.create += 1;
  const failure = takeFailure();
  if (failure === 'timeout') return; // never respond → client timeout
  if (failure === '500') return res.status(500).send('Internal Server Error');

  let data;
  try { data = JSON.parse(req.body.data); } catch { return res.json({ success: false, error: true, rmk: 'Invalid data', packages: [] }); }
  const s = data.shipments?.[0] || {};
  const fail = (remark) => res.json({ success: false, packages: [{ status: 'Fail', waybill: '', refnum: s.order, remarks: [remark] }], rmk: remark });

  if (data.pickup_location?.name !== PICKUP) return fail('ClientWarehouse matching query does not exist.');
  if (!s.pin || !/^\d{6}$/.test(String(s.pin)) || String(s.pin).startsWith('99')) return fail('Non serviceable pincode');
  if (!s.add || !s.phone || !s.name) return fail('Missing mandatory fields: add/phone/name');
  if ([...packages.values()].some((p) => p.order === s.order)) return fail(`Duplicate order id ${s.order}`);

  const waybill = String(Date.now()).slice(-8) + String(Math.floor(Math.random() * 1e6)).padStart(6, '0');
  const pkg = {
    waybill, order: s.order, payment_mode: s.payment_mode, name: s.name, pin: s.pin, weight: s.weight,
    status: { Status: 'Manifested', StatusType: 'UD', StatusDateTime: istNow(), StatusLocation: 'Sim_Origin (HQ)', Instructions: 'Manifested' },
    scans: [], created: istNow(),
  };
  pkg.scans.push({ ScanDetail: { Scan: 'Manifested', ScanType: 'UD', ScanDateTime: pkg.created, ScannedLocation: 'Sim_Origin (HQ)', Instructions: 'Manifested' } });
  packages.set(waybill, pkg);
  console.log(`[sim] created waybill=${waybill} order=${s.order} mode=${s.payment_mode} weight=${s.weight}g pickup=${data.pickup_location?.name}`);

  if (failure === 'accept-then-timeout') return; // accepted but client never hears back
  res.json({ success: true, package_count: 1, upload_wbn: `UPL${Date.now()}`, packages: [{ status: 'Success', waybill, refnum: s.order, remarks: [] }] });
});

const shipmentJson = (p) => ({
  Shipment: {
    AWB: p.waybill, ReferenceNo: p.order, OrderType: p.payment_mode, Status: p.status,
    PickUpDate: p.pickedAt || null, ExpectedDeliveryDate: p.edd || null,
    Scans: p.scans,
  },
});

app.get('/api/v1/packages/json/', auth, (req, res) => {
  counters.track += 1;
  const failure = takeFailure();
  if (failure === 'timeout') return;
  if (failure === '500') return res.status(500).send('Internal Server Error');
  let list = [];
  if (req.query.waybill) list = String(req.query.waybill).split(',').map((w) => packages.get(w.trim())).filter(Boolean);
  else if (req.query.ref_ids) list = [...packages.values()].filter((p) => String(req.query.ref_ids).split(',').includes(p.order));
  else return res.json({ Error: 'parameter ref_ids/ref_nos or waybill is required' });
  res.json({ ShipmentData: list.map(shipmentJson) });
});

app.post('/api/p/edit', auth, (req, res) => {
  counters.cancel += 1;
  const p = packages.get(String(req.body.waybill));
  if (!p) return res.status(400).json({ status: false, remark: 'Waybill not found' });
  if (!['Manifested', 'In Transit', 'Pending', 'Open', 'Scheduled', 'Not Picked'].includes(p.status.Status) || p.status.StatusType === 'DL') {
    return res.json({ status: false, waybill: p.waybill, remark: `Cannot cancel package in status ${p.status.Status}` });
  }
  p.status = { Status: 'Canceled', StatusType: 'CN', StatusDateTime: istNow(), StatusLocation: p.status.StatusLocation, Instructions: 'Seller cancelled the order' };
  p.scans.push({ ScanDetail: { Scan: 'Canceled', ScanType: 'CN', ScanDateTime: p.status.StatusDateTime, ScannedLocation: p.status.StatusLocation, Instructions: 'Seller cancelled the order' } });
  res.json({ status: true, waybill: p.waybill, remark: 'Shipment has been cancelled', order_id: p.order });
});

const pickups = new Map(); // `${location}|${date}` → pickup
app.post('/fm/request/new/', auth, (req, res) => {
  counters.pickup = (counters.pickup || 0) + 1;
  const { pickup_time, pickup_date, pickup_location, expected_package_count } = req.body || {};
  if (!pickup_time || !pickup_date || !pickup_location) return res.status(400).json({ error: 'Insufficient parameters specified' });
  if (pickup_location !== PICKUP) return res.status(400).json({ pickup_location: 'Invalid Pickup Location ClientWarehouse matching query does not exist.' });
  const key = `${pickup_location}|${pickup_date}`;
  if (pickups.has(key)) {
    const p = pickups.get(key);
    const msg = `A Pickup Request ${p.pickup_id} for this Pickup Location already exists`;
    return res.json({ data: { message: msg }, error: { code: 669, message: msg }, pickup_id: p.pickup_id, pr_exist: true, status: true, success: false });
  }
  const p = { pickup_id: 60000 + pickups.size + 1, client_name: 'CHILLFI', pickup_location_name: pickup_location, pickup_time, pickup_date, expected_package_count };
  pickups.set(key, p);
  console.log(`[sim] pickup ${p.pickup_id} ${pickup_date} ${pickup_time} count=${expected_package_count}`);
  res.status(201).json({ ...p, incoming_center_name: 'Sim_DC' });
});

app.get('/api/p/packing_slip', auth, (req, res) => {
  const list = String(req.query.wbns || '').split(',').map((w) => packages.get(w.trim())).filter(Boolean);
  res.json({
    packages_found: list.length,
    packages: list.map((p) => ({ wbn: p.waybill, oid: p.order, name: p.name, pin: p.pin, pt: p.payment_mode, weight: p.weight,
      pdf_download_link: req.query.pdf === 'true' ? `http://localhost:${PORT}/__sim/label/${p.waybill}.pdf` : undefined })),
  });
});
app.get('/__sim/label/:file', (req, res) => res.type('application/pdf').send('%PDF-1.4\n% simulated label\n'));

// ── test controls ──
const pushWebhook = async (body, token = WEBHOOK_SECRET) => {
  const r = await axios.post(WEBHOOK_URL, body, { headers: { Authorization: `Bearer ${token}` }, validateStatus: () => true, timeout: 15000 });
  return { status: r.status, body: r.data };
};

app.post('/__sim/advance', async (req, res) => {
  const { waybill, status_type, status, instructions, location = 'Sim_Hub (IN)', time, push = true } = req.body;
  const p = packages.get(String(waybill));
  if (!p) return res.status(404).json({ error: 'unknown waybill' });
  const at = time || istNow();
  p.status = { Status: status, StatusType: status_type, StatusDateTime: at, StatusLocation: location, Instructions: instructions || status };
  if (status === 'In Transit' && status_type === 'UD' && !p.pickedAt) p.pickedAt = at;
  p.scans.push({ ScanDetail: { Scan: status, ScanType: status_type, ScanDateTime: at, ScannedLocation: location, Instructions: instructions || status } });
  let webhook = null;
  if (push) {
    // Documented push payload shape
    webhook = await pushWebhook({ Shipment: { Status: p.status, PickUpDate: p.pickedAt || null, NSLCode: 'X-SIM', Sortcode: 'SIM/HUB', ReferenceNo: p.order, AWB: p.waybill } });
  }
  res.json({ ok: true, status: p.status, webhook });
});
app.post('/__sim/push-raw', async (req, res) => res.json(await pushWebhook(req.body.body, req.body.token ?? WEBHOOK_SECRET)));
app.post('/__sim/fail-next', (req, res) => { failNext = { mode: req.body.mode, times: req.body.times || 1 }; res.json(failNext); });
app.post('/__sim/config', (req, res) => { if (req.body.webhook_secret) WEBHOOK_SECRET = req.body.webhook_secret; res.json({ ok: true }); });
app.get('/__sim/packages', (req, res) => res.json({ counters, packages: [...packages.values()], pickups: [...pickups.values()] }));

app.listen(PORT, () => console.log(`[sim] Delhivery simulator on :${PORT} (pickup="${PICKUP}")`));
