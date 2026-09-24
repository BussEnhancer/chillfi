/**
 * Direct checks of ChillFi's Delhivery client against REAL Delhivery staging (not the simulator).
 * Complements test-delhivery-lifecycle.js (which drives the full order flow through the API).
 *
 *   node scripts/verify-delhivery-staging.js
 *
 * Refuses to run unless DELHIVERY_ENV=staging and the base URL is staging-express.delhivery.com.
 * Creates only STAGING test shipments (order numbers prefixed DLVTEST-) and cancels them.
 * Never prints the API token.
 */
require('dotenv').config({ quiet: true });
const axios = require('axios');
const pool = require('../src/db/pool');
const d = require('../src/utils/delhivery');

let pass = 0; let fail = 0; const failures = []; const notes = [];
const check = (name, cond, extra = '') => {
  if (cond) { pass += 1; console.log(`  PASS ${name}`); } else { fail += 1; failures.push(name); console.log(`  FAIL ${name} ${extra}`); }
};
const note = (s) => { notes.push(s); console.log(`  NOTE ${s}`); };
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const safe = async (fn) => { try { return { ok: true, v: await fn() }; } catch (e) { return { ok: false, e }; } };

const testOrder = (suffix, extra = {}) => ({
  order_number: `DLVTEST-${Date.now().toString().slice(-8)}${suffix}`,
  payment_method: 'PhonePe', total: 1178.82, created_at: new Date(),
  customer_name: 'DLV-TEST Customer', customer_phone: '9000000001',
  items: [{ name: 'boAt Airdopes 141 TWS', quantity: 1, price: 999 }],
  address: { name: 'DLV-TEST Customer', phone: '9000000001', line1: 'DLV-TEST 12 Test Street', line2: 'Connaught Place', city: 'New Delhi', state: 'Delhi', pincode: '110001' },
  ...extra,
});

(async () => {
  const cfg = await d.getConfig();
  if (cfg.env !== 'staging' || !/^https:\/\/staging-express\.delhivery\.com$/.test(cfg.baseUrl)) {
    console.error(`ABORT: expected real staging, got env=${cfg.env} base=${cfg.baseUrl}`); process.exit(2);
  }
  console.log(`Real Delhivery staging: ${cfg.baseUrl}  pickup="${cfg.pickupLocation}"  weight=${cfg.weightGrams}g`);

  // ── 1. Configuration & connectivity ─────────────────────────────────────
  console.log('\n[1] Configuration & connectivity');
  check('config complete for staging', d.configProblems(cfg).length === 0);
  const conn = await d.testConnection('110001');
  check('Test connection OK', conn.ok, conn.message);
  const badTok = await safe(async () => {
    const r = await axios.get(`${cfg.baseUrl}/c/api/pin-codes/json/`, { params: { filter_codes: '110001' }, headers: { Authorization: 'Token invalid-token-xyz' }, validateStatus: () => true, timeout: 15000 });
    return r.status;
  });
  check('invalid token is rejected by Delhivery (401/403)', badTok.ok && [401, 403].includes(badTok.v), `status=${badTok.v}`);

  // ── 2. Pincode serviceability ───────────────────────────────────────────
  console.log('\n[2] Pincode serviceability');
  const p1 = await d.checkPincode('110001');
  check('110001 serviceable (prepaid flag present)', p1.serviceable && typeof p1.prepaid === 'boolean', JSON.stringify(p1));
  const p2 = await d.checkPincode('000000');
  check('invalid pincode 000000 → not serviceable', !p2.serviceable, JSON.stringify(p2));
  const p3 = await d.checkPincode('491335');
  note(`Bemetara 491335 on staging: ${p3.serviceable ? 'serviceable' : 'NOT in staging data (expected — staging has few pincodes)'}`);

  // ── 3. Shipment creation ────────────────────────────────────────────────
  console.log('\n[3] Shipment creation (prepaid)');
  const o1 = testOrder('A');
  const c1 = await safe(() => d.createShipment(o1));
  check('prepaid shipment created, AWB returned', c1.ok && /^\d{10,}$/.test(c1.v.waybill), c1.ok ? '' : c1.e.message);
  const awb1 = c1.ok ? c1.v.waybill : null;

  console.log('\n[3b] Duplicate order protection (real Delhivery response)');
  const dup = await safe(() => d.createShipment(o1));
  if (dup.ok) {
    check('re-sending same order → SAME AWB recovered (no second shipment)', dup.v.waybill === awb1 && dup.v.recovered === true, JSON.stringify(dup.v));
  } else {
    check('re-sending same order → SAME AWB recovered (no second shipment)', false, `Delhivery said: ${dup.e.message}`);
  }
  const byRef = await safe(() => d.findWaybillByOrderRef(o1.order_number));
  check('lookup AWB by order number (ref_ids)', byRef.ok && byRef.v === awb1, JSON.stringify(byRef.ok ? byRef.v : byRef.e.message));

  console.log('\n[3c] Rejections are clear and non-fatal');
  const cod = await safe(() => d.createShipment(testOrder('B', { payment_method: 'COD' })));
  if (cod.ok) note(`COD accepted on staging now (AWB ${cod.v.waybill}) — COD is enabled`);
  else check('COD on this staging account → clear rejection message', /COD/i.test(cod.e.message) && cod.e.code === 'REJECTED', cod.e.message);
  const badPin = await safe(() => d.createShipment(testOrder('C', { address: { ...testOrder('x').address, pincode: '000000' } })));
  check('non-serviceable pincode → rejected (not a crash)', !badPin.ok && ['REJECTED', 'HTTP'].includes(badPin.e.code), badPin.ok ? `unexpected AWB ${badPin.v.waybill}` : badPin.e.message);
  const badAddr = await safe(() => d.createShipment(testOrder('D', { address: { ...testOrder('x').address, line1: '' } })));
  check('missing address → blocked locally before calling Delhivery', !badAddr.ok && badAddr.e.code === 'INVALID_ADDRESS');

  // ── 4. Tracking (pull) ──────────────────────────────────────────────────
  console.log('\n[4] Tracking');
  await sleep(2000);
  const t1 = await safe(() => d.trackShipment(awb1));
  check('track by AWB returns shipment', t1.ok && t1.v && t1.v.waybill === awb1, t1.ok ? '' : t1.e.message);
  if (t1.ok && t1.v) {
    check('status + status_type parsed', !!t1.v.status && !!t1.v.status_type, JSON.stringify({ s: t1.v.status, t: t1.v.status_type }));
    const skew = t1.v.status_time ? Math.abs(Date.now() - t1.v.status_time.getTime()) / 60000 : null;
    check('status time parsed as IST (within 30 min of now)', skew !== null && skew < 30, `skew=${skew} min, raw=${t1.v.status_time}`);
    check('scan history parsed', Array.isArray(t1.v.scans) && t1.v.scans.length >= 1, `scans=${t1.v.scans?.length}`);
    note(`live staging status for new AWB: ${t1.v.status_type}/${t1.v.status} at ${t1.v.location || '-'}`);
  }
  const existing = (await pool.query(`SELECT tracking_id FROM orders WHERE shipment_env='staging' AND tracking_id ~ '^[0-9]+$' ORDER BY shipment_created_at DESC NULLS LAST LIMIT 5`)).rows.map((r) => r.tracking_id);
  const batch = await safe(() => d.trackWaybills([awb1, ...existing].slice(0, 6)));
  check('batch tracking (several AWBs in one call)', batch.ok && batch.v.length >= 2, batch.ok ? `got ${batch.v.length}` : batch.e.message);
  const unknown = await safe(() => d.trackShipment('99999999999999'));
  check('unknown AWB → handled (null / error, no crash)', unknown.ok ? unknown.v === null : !!unknown.e.message);

  // ── 5. Label ────────────────────────────────────────────────────────────
  console.log('\n[5] Shipping label');
  const lb = await safe(() => d.getPackingSlip(awb1));
  check('label request returns PDF link', lb.ok && /^https:\/\//.test(lb.v.pdf_url || ''), lb.ok ? JSON.stringify(Object.keys(lb.v.package || {})) : lb.e.message);
  if (lb.ok && lb.v.pdf_url) {
    const pdf = await axios.get(lb.v.pdf_url, { responseType: 'arraybuffer', validateStatus: () => true, timeout: 20000 });
    const head = Buffer.from(pdf.data).slice(0, 5).toString();
    check('label PDF actually downloads and is a PDF', pdf.status === 200 && head === '%PDF-', `status=${pdf.status} head=${head}`);
  }

  // ── 6. Pickup ───────────────────────────────────────────────────────────
  console.log('\n[6] Pickup request');
  const tomorrow = new Date(Date.now() + 5.5 * 3600e3 + 86400e3).toISOString().slice(0, 10);
  const pk1 = await safe(() => d.requestPickup({ date: tomorrow, time: '14:00:00', count: 1 }));
  check('pickup request accepted (new or already booked)', pk1.ok && pk1.v.ok, pk1.ok ? JSON.stringify(pk1.v).slice(0, 160) : pk1.e.message);
  const pk2 = await safe(() => d.requestPickup({ date: tomorrow, time: '14:00:00', count: 1 }));
  check('repeat pickup request → treated as already booked', pk2.ok && pk2.v.ok && pk2.v.existing, pk2.ok ? JSON.stringify(pk2.v).slice(0, 160) : pk2.e.message);

  // ── 7. Cancellation ─────────────────────────────────────────────────────
  console.log('\n[7] Cancellation');
  const cx = await safe(() => d.cancelShipment(awb1));
  check('cancel manifested shipment accepted by Delhivery', cx.ok && cx.v.cancelled, cx.ok ? '' : cx.e.message);
  await sleep(2000);
  const t2 = await safe(() => d.trackShipment(awb1));
  note(`after cancel Delhivery reports: ${t2.ok && t2.v ? `${t2.v.status_type}/${t2.v.status}` : 'n/a'}`);
  const cx2 = await safe(() => d.cancelShipment(awb1));
  note(`cancelling again: ${cx2.ok ? `accepted (${cx2.v.remark || 'ok'})` : `refused: ${cx2.e.message.slice(0, 120)}`}`);
  const cx3 = await safe(() => d.cancelShipment('99999999999999'));
  check('cancel unknown AWB → refused with message (no crash)', !cx3.ok && !!cx3.e.message, cx3.ok ? 'unexpectedly accepted' : '');

  console.log(`\n==== ${pass} passed, ${fail} failed ====`);
  if (failures.length) console.log('Failures:\n - ' + failures.join('\n - '));
  if (notes.length) console.log('Notes:\n - ' + notes.join('\n - '));
  process.exit(fail ? 1 : 0);
})().catch((e) => { console.error('ERROR', e.message); process.exit(1); });
