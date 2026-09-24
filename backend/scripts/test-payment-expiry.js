/**
 * Regression test: abandoned online-payment orders + late payments (LOCAL DB ONLY).
 *   ADMIN_TOKEN, CUSTOMER_TOKEN, PRODUCT_ID, ADDRESS_ID  (a throwaway coupon is created and deleted)
 *   node scripts/test-payment-expiry.js
 * Places one PhonePe order (never paid), backdates it, runs the expiry job and checks: cancelled, stock + coupon
 * released, customer told. Then simulates a late payment on it and checks a refund opens (and no "confirmed").
 */
require('dotenv').config({ path: `${__dirname}/../.env`, quiet: true });
const axios = require('axios');
const pool = require('../src/db/pool');
const { expireUnpaidOrders } = require('../src/services/paymentExpiry');
const { onOrderPaid } = require('../src/services/shipmentService');

const API = process.env.API || 'http://localhost:5000/api';
const admin = axios.create({ baseURL: API, headers: { Authorization: `Bearer ${process.env.ADMIN_TOKEN}` }, validateStatus: () => true });
const cust = axios.create({ baseURL: API, headers: { Authorization: `Bearer ${process.env.CUSTOMER_TOKEN}` }, validateStatus: () => true });
let pass = 0; let fail = 0;
const check = (n, c, x = '') => { if (c) { pass += 1; console.log(`  PASS ${n}`); } else { fail += 1; console.log(`  FAIL ${n} ${x}`); } };
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

(async () => {
  if (process.env.NODE_ENV === 'production') throw new Error('refusing to run against production');
  const P = process.env.PRODUCT_ID;
  const stock0 = +(await pool.query('SELECT stock FROM products WHERE id=$1', [P])).rows[0].stock;
  const CODE = `QAEXP${Date.now().toString().slice(-6)}`;
  const cr = await admin.post('/admin/coupons', { code: CODE, type: 'Percentage', value: 10, min_order: 0 });
  const coupon = (await pool.query('SELECT id, used_count FROM coupons WHERE code=$1', [CODE])).rows[0];
  if (!coupon) throw new Error(`could not create test coupon: ${JSON.stringify(cr.data)}`);
  // Old unpaid orders that DO have a payment attempt: with PhonePe unconfigured they must be skipped, never cancelled.
  const withAttempt = (await pool.query(`SELECT o.id FROM orders o WHERE o.payment_method <> 'COD' AND o.payment_status <> 'Paid'
    AND o.status = 'Processing' AND o.tracking_id IS NULL AND o.created_at < NOW() - INTERVAL '120 minutes'
    AND EXISTS (SELECT 1 FROM payments p WHERE p.order_id = o.id)`)).rows.map((x) => x.id);

  await cust.delete('/cart/clear'); await cust.post('/cart/add', { product_id: P, quantity: 1 });
  const r = await cust.post('/orders', { address_id: process.env.ADDRESS_ID, payment_method: 'PhonePe', coupon_code: CODE, notes: 'QA payment-expiry test' });
  const order = r.data?.data?.order;
  check('unpaid PhonePe order placed with coupon', r.status < 300 && order?.coupon_id, JSON.stringify(r.data).slice(0, 160));
  const stock1 = +(await pool.query('SELECT stock FROM products WHERE id=$1', [P])).rows[0].stock;
  check('stock reserved', stock1 === stock0 - 1, `${stock0}→${stock1}`);

  // Fresh order must NOT be touched.
  let res = await expireUnpaidOrders({ ttlMin: 120 });
  let o = (await pool.query('SELECT * FROM orders WHERE id=$1', [order.id])).rows[0];
  check('fresh unpaid order left alone', o.status === 'Processing', o.status);

  // Backdate (test order only) and expire.
  await pool.query(`UPDATE orders SET created_at = NOW() - INTERVAL '3 hours' WHERE id=$1`, [order.id]);
  res = await expireUnpaidOrders({ ttlMin: 120 });
  o = (await pool.query('SELECT * FROM orders WHERE id=$1', [order.id])).rows[0];
  check('abandoned order auto-cancelled', o.status === 'Cancelled' && o.payment_status === 'Failed', `${o.status}/${o.payment_status} ${JSON.stringify(res)}`);
  const stock2 = +(await pool.query('SELECT stock FROM products WHERE id=$1', [P])).rows[0].stock;
  check('stock restored', stock2 === stock0, `${stock0}→${stock2}`);
  const cu = (await pool.query('SELECT used_count FROM coupons WHERE id=$1', [coupon.id])).rows[0];
  const usage = (await pool.query('SELECT 1 FROM coupon_usage WHERE order_id=$1', [order.id])).rows.length;
  check('coupon released (usage row + count)', !usage && +cu.used_count === +coupon.used_count, `used ${coupon.used_count}→${cu.used_count}, usage rows ${usage}`);
  await sleep(500);
  const n1 = (await cust.get('/profile/notifications?limit=20')).data?.data; const l1 = n1.notifications || n1;
  check('customer told payment not completed', l1.some((x) => /payment not completed/i.test(x.title) && x.body.includes(order.order_number)));

  // Orders with a payment attempt but an unreachable/unconfigured gateway are never cancelled.
  const phonepeReady = !require('../src/utils/phonepe').configProblems(await require('../src/utils/phonepe').getConfig()).length;
  if (!phonepeReady && withAttempt.length) {
    const still = (await pool.query(`SELECT count(*)::int AS n FROM orders WHERE id = ANY($1::uuid[]) AND status = 'Processing'`, [withAttempt])).rows[0].n;
    check('uncertain gateway (PhonePe not configured) → orders with a payment attempt kept', still === withAttempt.length, `${still}/${withAttempt.length}`);
  }

  // Late payment for the cancelled order → refund, never "confirmed" or shipped.
  await pool.query(`UPDATE orders SET payment_status='Paid' WHERE id=$1`, [order.id]);
  await onOrderPaid(order.id, 'qa-late-payment');
  const rr = (await pool.query(`SELECT status, refund_amount FROM refund_requests WHERE order_id=$1`, [order.id])).rows;
  check('late payment opens refund request for full amount', rr.length === 1 && +rr[0].refund_amount === +o.total, JSON.stringify(rr));
  await sleep(500);
  const n2 = (await cust.get('/profile/notifications?limit=20')).data?.data; const l2 = n2.notifications || n2;
  check('customer told refund started', l2.some((x) => x.title === 'Refund started' && x.body.includes(order.order_number)));
  check('no "Order confirmed" sent for cancelled order', !l2.some((x) => x.title === 'Order confirmed' && x.body.includes(order.order_number)));
  const o2 = (await pool.query('SELECT status, tracking_id FROM orders WHERE id=$1', [order.id])).rows[0];
  check('cancelled order not shipped', o2.status === 'Cancelled' && !o2.tracking_id);
  await onOrderPaid(order.id, 'qa-late-payment-dup');
  const rr2 = (await pool.query(`SELECT 1 FROM refund_requests WHERE order_id=$1`, [order.id])).rows;
  check('duplicate payment event → still one refund', rr2.length === 1);

  await admin.delete(`/admin/coupons/${coupon.id}`);
  console.log(`==== ${pass} passed, ${fail} failed ====`);
  await pool.end(); process.exit(fail ? 1 : 0);
})().catch(async (e) => { console.error(e); process.exit(1); });
