/**
 * End-to-end API test of the ChillFi ⇄ Delhivery shipment lifecycle (TEST/STAGING ONLY).
 *
 *   node scripts/test-delhivery-lifecycle.js
 *   env: API (http://localhost:5000/api), ADMIN_TOKEN, CUSTOMER_TOKEN, WEBHOOK_SECRET,
 *        PRODUCT_ID, ADDRESS_ID, SIM_URL (optional — enables simulator-only fault-injection cases)
 *
 * Refuses to run unless the backend reports DELHIVERY_ENV=staging.
 * Webhook events are posted in Delhivery's documented push format directly to ChillFi,
 * so the same script validates status sync against a real staging shipment.
 */
const axios = require('axios');

const API = process.env.API || 'http://localhost:5000/api';
const SIM = process.env.SIM_URL || null;
const admin = axios.create({ baseURL: API, headers: { Authorization: `Bearer ${process.env.ADMIN_TOKEN}` }, validateStatus: () => true, timeout: 60000 });
const cust = axios.create({ baseURL: API, headers: { Authorization: `Bearer ${process.env.CUSTOMER_TOKEN}` }, validateStatus: () => true, timeout: 60000 });
const hook = (body, token = process.env.WEBHOOK_SECRET, headers = {}) => axios.post(`${API}/shipping/delhivery/webhook`, body, {
  headers: { Authorization: `Bearer ${token}`, ...headers }, validateStatus: () => true,
});
const sim = SIM && axios.create({ baseURL: SIM, validateStatus: () => true });

let pass = 0; let fail = 0; const failures = [];
const check = (name, cond, extra = '') => {
  if (cond) { pass += 1; console.log(`  PASS ${name}`); } else { fail += 1; failures.push(name); console.log(`  FAIL ${name} ${extra}`); }
};
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const ist = (offsetMin = 0) => new Date(Date.now() + offsetMin * 60e3 + 5.5 * 3600e3).toISOString().slice(0, 19);
const push = (awb, type, status, time, extra = {}) => hook({ Shipment: { Status: { Status: status, StatusType: type, StatusDateTime: time, StatusLocation: 'Test_Hub (DL)', Instructions: extra.instructions || status }, AWB: awb, ReferenceNo: extra.ref || '', NSLCode: 'X', Sortcode: 'T/T', PickUpDate: null } });

const getOrder = async (id) => (await cust.get(`/orders/${id}`)).data?.data?.order;
const waitFor = async (fn, ms = 15000) => { const end = Date.now() + ms; while (Date.now() < end) { const v = await fn(); if (v) return v; await sleep(500); } return null; };
const notifs = async () => (await cust.get('/profile/notifications?limit=100')).data?.data || [];

// TEST_PREPAID=1: accounts without COD enabled (e.g. a fresh Delhivery staging account) —
// place every order as prepaid and pay it via the dev-mode test payment (no real money).
// The dev payment only exists when the backend runs with NODE_ENV=development AND PAYMENT_DEV_AUTOPAY=true.
const placeOrder = async (method = 'COD') => {
  if (process.env.TEST_PREPAID && method === 'COD') {
    const o = await placeOrderRaw('PhonePe');
    const init = await cust.post('/payment/initiate', { order_id: o.id, amount: o.total });
    await cust.post('/payment/verify', { order_id: o.id, merchant_txn_id: init.data?.data?.merchant_txn_id });
    return o;
  }
  return placeOrderRaw(method);
};
const placeOrderRaw = async (method) => {
  await cust.delete('/cart/clear');
  const add = await cust.post('/cart/add', { product_id: process.env.PRODUCT_ID, quantity: 1 });
  if (!add.data?.success) throw new Error(`cart add failed: ${JSON.stringify(add.data)}`);
  const r = await cust.post('/orders', { address_id: process.env.ADDRESS_ID, payment_method: method, notes: 'DLV-TEST automated order' });
  if (r.status !== 201) throw new Error(`order create failed: ${JSON.stringify(r.data)}`);
  return r.data.data.order;
};

(async () => {
  const status = (await admin.get('/admin/shipping/delhivery/status')).data?.data;
  if (status?.environment !== 'staging') { console.error(`ABORT: Delhivery environment is "${status?.environment}", expected staging`); process.exit(2); }
  console.log(`Delhivery env=${status.environment} base=${status.base_url} configured=${status.configured}`);

  // ── A. COD order → auto shipment ───────────────────────────────────────
  console.log('\n[A] COD order auto-ships');
  const o = await placeOrder('COD');
  if (!process.env.TEST_PREPAID) await cust.post('/payment/cod-confirm', { order_id: o.id });
  const shipped = await waitFor(async () => { const x = await getOrder(o.id); return x?.tracking_id ? x : null; });
  check('AWB assigned automatically', !!shipped?.tracking_id, JSON.stringify(shipped && { s: shipped.shipping_status, e: shipped.shipment_error }));
  if (!shipped) return summary();
  const awb = shipped.tracking_id;
  check('shipping_status = manifested', shipped.shipping_status === 'manifested');
  check('order status still Processing (not Shipped before pickup)', shipped.status === 'Processing');
  check('shipment_provider = delhivery, env staging', shipped.shipment_provider === 'delhivery' && shipped.shipment_env === 'staging');

  // idempotency
  const again = await admin.post(`/admin/orders/${o.id}/ship`, {});
  check('admin re-ship rejected (no duplicate shipment)', again.status === 400 && /already/i.test(again.data.message));
  const parallel = await Promise.all([1, 2, 3].map(() => admin.post(`/admin/orders/${o.id}/ship`, {})));
  check('parallel re-ship attempts all rejected', parallel.every((r) => r.status === 400));
  const afterRe = await getOrder(o.id);
  check('AWB unchanged after retries', afterRe.tracking_id === awb);

  // tracking visible to customer + admin
  const t1 = (await cust.get(`/orders/${o.id}/tracking`)).data?.data;
  check('customer tracking returns waybill + scans', t1?.waybill === awb && Array.isArray(t1.scans) && t1.scans.length >= 1);
  const t1a = (await admin.get(`/admin/orders/${o.id}/tracking`)).data?.data;
  check('admin tracking matches customer tracking', t1a?.waybill === awb && t1a.shipping_status === t1.shipping_status);

  // ── B. Webhook lifecycle ───────────────────────────────────────────────
  console.log('\n[B] Webhook-driven lifecycle');
  const tInTransit = ist(1); // identical payload twice = a genuine Delhivery retry
  let r = await push(awb, 'UD', 'In Transit', tInTransit);
  check('webhook In Transit accepted', r.status === 200 && r.data.results?.[0]?.applied, JSON.stringify(r.data));
  let x = await getOrder(o.id);
  check('→ order Shipped / in_transit', x.status === 'Shipped' && x.shipping_status === 'in_transit');

  r = await push(awb, 'UD', 'In Transit', tInTransit);
  check('duplicate webhook ignored', r.status === 200 && r.data.results?.[0]?.duplicate === true);

  r = await push(awb, 'UD', 'Pending', ist(2), { instructions: 'Shipment received at facility' });
  x = await getOrder(o.id);
  check('Pending → at_destination_hub', x.shipping_status === 'at_destination_hub');

  r = await push(awb, 'UD', 'Manifested', ist(-60));
  x = await getOrder(o.id);
  check('out-of-order (older) event not applied', r.data.results?.[0]?.applied === false && x.shipping_status === 'at_destination_hub');

  r = await push(awb, 'UD', 'Dispatched', ist(3), { instructions: 'Out for delivery' });
  x = await getOrder(o.id);
  check('Dispatched → out_for_delivery, still not Delivered', x.shipping_status === 'out_for_delivery' && x.status === 'Shipped');

  r = await push(awb, 'UD', 'Pending', ist(4), { instructions: 'Consignee unavailable' });
  x = await getOrder(o.id);
  check('failed attempt (OFD → Pending) applied', x.shipping_status === 'at_destination_hub');

  r = await push(awb, 'XX', 'Weird New Status', ist(5));
  x = await getOrder(o.id);
  check('unknown status recorded, order unchanged', r.status === 200 && r.data.results?.[0]?.applied === false && x.shipping_status === 'at_destination_hub');

  r = await push(awb, 'UD', 'Dispatched', ist(6));
  r = await push(awb, 'DL', 'Delivered', ist(7), { instructions: 'Delivered to consignee' });
  x = await getOrder(o.id);
  check('Delivered → order Delivered', x.status === 'Delivered' && x.shipping_status === 'delivered');
  check('COD payment marked Paid on delivery', x.payment_status === 'Paid');

  r = await push(awb, 'UD', 'In Transit', ist(8));
  x = await getOrder(o.id);
  check('event after Delivered cannot regress order', x.status === 'Delivered' && r.data.results?.[0]?.applied === false);

  const t2 = (await cust.get(`/orders/${o.id}/tracking`)).data?.data;
  check('tracking timeline has full history', t2?.scans?.length >= 6, `len=${t2?.scans?.length}`);
  const list = (await cust.get('/orders?limit=50')).data?.data?.orders || [];
  check('order list shows Delivered', list.find((q) => q.id === o.id)?.status === 'Delivered');
  const aList = (await admin.get(`/admin/orders?search=${o.order_number}`)).data?.data?.orders || [];
  check('admin list shows Delivered + AWB', aList[0]?.status === 'Delivered' && aList[0]?.tracking_id === awb);

  // notifications
  const ns = (await notifs()).filter((n) => n.data?.order_id === o.id);
  const types = ns.map((n) => n.data?.shipping_status || 'placed');
  console.log(`  notifications for order: ${JSON.stringify(types)}`);
  for (const need of ['placed', 'manifested', 'in_transit', 'out_for_delivery', 'delivery_attempt_failed', 'delivered']) {
    check(`notification: ${need}`, types.includes(need));
  }
  check('no duplicate notifications', new Set(ns.map((n) => n.title + (n.data?.shipping_status || '') + n.body)).size === ns.length);

  // ── A2. Pickup + label ────────────────────────────────────────────────
  console.log('\n[A2] Pickup booking + shipping label');
  const dstat = (await admin.get('/admin/shipping/delhivery/status')).data?.data;
  check('pickup auto-booked after shipment creation', !!dstat?.pickup?.last?.ok, JSON.stringify(dstat?.pickup));
  const pk = await admin.post('/admin/shipping/delhivery/pickup', {});
  check('manual pickup request handled (booked or already-booked)', pk.status === 200 && pk.data.success, JSON.stringify(pk.data));
  const lbl = await admin.get(`/admin/orders/${o.id}/label`);
  check('shipping label available for AWB', lbl.status === 200 && lbl.data?.data?.waybill === awb, JSON.stringify(lbl.data).slice(0, 200));
  const lblNone = await admin.get('/admin/orders/00000000-0000-0000-0000-000000000000/label');
  check('label for unknown order → 404', lblNone.status === 404);

  // ── C. Webhook security / validation ───────────────────────────────────
  console.log('\n[C] Webhook security');
  check('bad token → 401', (await hook({ Shipment: { AWB: awb, Status: { Status: 'Delivered', StatusType: 'DL' } } }, 'wrong-token')).status === 401);
  check('no token → 401', (await axios.post(`${API}/shipping/delhivery/webhook`, { Shipment: { AWB: awb } }, { validateStatus: () => true })).status === 401);
  check('invalid payload → 400', (await hook({ foo: 'bar' })).status === 400);
  check('unknown AWB → 200, not matched', (await hook({ Shipment: { AWB: '999999999999', Status: { Status: 'In Transit', StatusType: 'UD', StatusDateTime: ist() } } })).data.results?.[0]?.matched === false);

  // ── D. Cancellation ────────────────────────────────────────────────────
  console.log('\n[D] Cancellation');
  const c = await placeOrder('COD');
  const cs = await waitFor(async () => { const q = await getOrder(c.id); return q?.tracking_id ? q : null; });
  const cc = await cust.post(`/orders/${c.id}/cancel`, { reason: 'DLV-TEST cancel before pickup' });
  const cq = await getOrder(c.id);
  check('cancel before pickup → order Cancelled + shipment cancelled', cc.status === 200 && cq.status === 'Cancelled' && cq.shipping_status === 'cancelled', JSON.stringify(cc.data));
  r = await push(cs.tracking_id, 'UD', 'In Transit', ist(10));
  check('late courier event after cancel does not revive order', (await getOrder(c.id)).status === 'Cancelled');

  const d = await placeOrder('COD');
  const ds = await waitFor(async () => { const q = await getOrder(d.id); return q?.tracking_id ? q : null; });
  await push(ds.tracking_id, 'UD', 'In Transit', ist(1));
  const dc = await cust.post(`/orders/${d.id}/cancel`, { reason: 'DLV-TEST cancel after pickup' });
  check('cancel after pickup refused (409)', dc.status === 409, JSON.stringify(dc.data));
  check('refused cancel leaves order Shipped', (await getOrder(d.id)).status === 'Shipped');
  // RTO path on this order
  await push(ds.tracking_id, 'RT', 'In Transit', ist(3));
  let dq = await getOrder(d.id);
  check('RT In Transit → rto_in_transit', dq.shipping_status === 'rto_in_transit');
  await push(ds.tracking_id, 'DL', 'RTO', ist(5));
  dq = await getOrder(d.id);
  check('DL RTO → rto_delivered, order Cancelled (never Delivered)', dq.shipping_status === 'rto_delivered' && dq.status === 'Cancelled');

  // ── E. Prepaid order ships only once Paid ─────────────────────────────
  console.log('\n[E] Prepaid order waits for payment');
  const p = await placeOrder('PhonePe');
  await sleep(2500);
  check('unpaid prepaid order NOT shipped', !(await getOrder(p.id)).tracking_id);
  const init = await cust.post('/payment/initiate', { order_id: p.id, amount: p.total });
  const v = await cust.post('/payment/verify', { order_id: p.id, merchant_txn_id: init.data?.data?.merchant_txn_id });
  check('test payment verified (dev mode, no real money)', v.data?.data?.status === 'SUCCESS', JSON.stringify(v.data));
  const cc2 = await cust.post('/payment/cod-confirm', { order_id: p.id });
  check('cod-confirm cannot downgrade a paid prepaid order', cc2.status === 400 && (await getOrder(p.id)).payment_status === 'Paid');
  const ps = await waitFor(async () => { const q = await getOrder(p.id); return q?.tracking_id ? q : null; });
  check('paid prepaid order auto-ships', !!ps?.tracking_id);

  // ── F. Fault injection (simulator only) ────────────────────────────────
  if (sim) {
    console.log('\n[F] Failure handling (simulator)');
    await sim.post('/__sim/fail-next', { mode: '500' });
    const f1 = await placeOrder('COD');
    const f1s = await waitFor(async () => { const q = await getOrder(f1.id); return q?.shipping_status === 'failed' ? q : null; });
    check('Delhivery 500 → order kept, shipping_status failed', !!f1s && f1s.status === 'Processing', JSON.stringify(f1s && f1s.shipment_error));
    const f1r = await admin.post(`/admin/orders/${f1.id}/ship`, {});
    check('admin retry after failure creates shipment', f1r.status === 200 && !!f1r.data.data?.awb, JSON.stringify(f1r.data));

    await sim.post('/__sim/fail-next', { mode: 'accept-then-timeout' });
    const f2 = await placeOrder('COD');
    const f2s = await waitFor(async () => { const q = await getOrder(f2.id); return q?.shipping_status === 'failed' ? q : null; }, 40000);
    check('Delhivery accepted-but-timed-out → marked failed', !!f2s, JSON.stringify(await getOrder(f2.id)));
    const f2r = await admin.post(`/admin/orders/${f2.id}/ship`, {});
    const pk = (await sim.get('/__sim/packages')).data.packages.filter((q) => q.order === f2.order_number);
    check('retry recovers existing waybill (exactly one Delhivery shipment)', f2r.status === 200 && pk.length === 1 && f2r.data.data?.awb === pk[0].waybill, JSON.stringify(f2r.data));

    // invalid pincode
    const badAddr = await cust.post('/addresses', { name: 'DLV-TEST Bad Pin', phone: '9000000001', line1: 'DLV-TEST Nowhere', city: 'Nowhere', state: 'Delhi', pincode: '999999', label: 'Other' });
    const badId = badAddr.data?.data?.id || badAddr.data?.data?.address?.id;
    if (badId) {
      await cust.delete('/cart/clear'); await cust.post('/cart/add', { product_id: process.env.PRODUCT_ID, quantity: 1 });
      // Since the checkout serviceability check, an undeliverable pincode is refused BEFORE an order exists.
      const br = await cust.post('/orders', { address_id: badId, payment_method: 'COD', notes: 'DLV-TEST bad pincode' });
      check('non-serviceable pincode → order refused up-front (no paid/undeliverable order)', br.status === 400 && /can't deliver/i.test(br.data?.message || ''), JSON.stringify(br.data));
      const svc = await cust.get('/shipping/pincode/999999');
      check('serviceability endpoint reports 999999 not serviceable', svc.data?.data?.serviceable === false, JSON.stringify(svc.data));
      await cust.delete(`/addresses/${badId}`); // don't pile up test addresses
    } else console.log('  (skipped bad-pincode case: address create failed)', JSON.stringify(badAddr.data));

    // polling fallback: change status in simulator WITHOUT webhook, then sync
    const g = await placeOrder('COD');
    const gs = await waitFor(async () => { const q = await getOrder(g.id); return q?.tracking_id ? q : null; });
    await sim.post('/__sim/advance', { waybill: gs.tracking_id, status_type: 'UD', status: 'In Transit', push: false });
    await sim.post('/__sim/advance', { waybill: gs.tracking_id, status_type: 'DL', status: 'Delivered', push: false });
    const sy = await admin.post(`/admin/orders/${g.id}/sync-tracking`);
    const gq = await getOrder(g.id);
    check('poll sync (no webhook) reaches Delivered', gq.status === 'Delivered' && gq.shipping_status === 'delivered', JSON.stringify(sy.data?.data?.summary));

    await sim.post('/__sim/fail-next', { mode: '500', times: 3 });
    const tr = await cust.get(`/orders/${o.id}/tracking`);
    check('tracking API failure still serves stored timeline', tr.status === 200 && tr.data?.data?.scans?.length > 0);
    await sim.post('/__sim/fail-next', { mode: null, times: 0 });
  }
  summary();
})().catch((e) => { console.error('ERROR', e.message); fail += 1; summary(); });

function summary() {
  console.log(`\n==== ${pass} passed, ${fail} failed ====`);
  if (failures.length) console.log('Failures:\n - ' + failures.join('\n - '));
  process.exit(fail ? 1 : 0);
}
