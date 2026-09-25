// Auto-cancels online (non-COD) orders whose payment was never completed, so abandoned checkouts
// don't hold stock and coupons forever.
//  - No payment attempt at all            → cancel.
//  - PhonePe status says FAILED / PENDING → cancel (a late success is still refunded: see onOrderPaid).
//  - PhonePe status says COMPLETED        → mark Paid instead (missed webhook).
//  - Gateway unreachable / not configured → leave the order alone and try again next run.
const axios = require('axios');
const pool = require('../db/pool');
const phonepe = require('../utils/phonepe');
const { notifyUser } = require('../utils/notify');

const TTL_MIN = () => Math.max(30, parseInt(process.env.UNPAID_ORDER_TTL_MIN || '120', 10) || 120);

const gatewayStatus = async (merchantTxnId) => {
  const cfg = await phonepe.getConfig();
  if (phonepe.configProblems(cfg).length) throw new Error('PhonePe not configured');
  // Sandbox answers are meaningless for a production order: never mark Paid from them (orders stay for manual review).
  if (phonepe.sandboxInProduction(cfg)) throw new Error('PhonePe sandbox on production');
  const path = `/pg/v1/status/${cfg.merchantId}/${merchantTxnId}`;
  const r = await axios.get(`${cfg.baseUrl}${path}`, {
    headers: { 'X-VERIFY': phonepe.xVerify(cfg, path), 'X-MERCHANT-ID': cfg.merchantId }, timeout: 15000,
  });
  const state = r.data?.data?.state;
  return { status: state === 'COMPLETED' ? 'SUCCESS' : state === 'FAILED' ? 'FAILED' : 'PENDING', raw: r.data };
};

const cancelUnpaid = async (order) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const upd = await client.query(
      `UPDATE orders SET status = 'Cancelled', payment_status = 'Failed',
         notes = TRIM(BOTH ' ' FROM COALESCE(notes, '') || ' [Auto-cancelled: online payment not completed]'), updated_at = NOW()
       WHERE id = $1 AND status IN ('Pending','Processing') AND payment_status <> 'Paid' AND tracking_id IS NULL RETURNING id`,
      [order.id]
    );
    if (!upd.rows.length) { await client.query('ROLLBACK'); return false; }
    const items = await client.query('SELECT product_id, quantity FROM order_items WHERE order_id = $1', [order.id]);
    for (const it of items.rows) await client.query('UPDATE products SET stock = stock + $1 WHERE id = $2', [it.quantity, it.product_id]);
    if (order.coupon_id) {
      const del = await client.query('DELETE FROM coupon_usage WHERE order_id = $1 RETURNING 1', [order.id]);
      if (del.rows.length) await client.query('UPDATE coupons SET used_count = GREATEST(used_count - 1, 0) WHERE id = $1', [order.coupon_id]);
    }
    await client.query('COMMIT');
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally { client.release(); }
  notifyUser(order.user_id, {
    title: 'Order cancelled — payment not completed',
    body: `We didn't receive payment for order ${order.order_number}, so it has been cancelled. If any amount was deducted, it will be refunded automatically.`,
    data: { order_id: order.id, order_number: order.order_number },
    dedupeKey: `order:${order.id}:cancelled`,
    storeSettingKey: 'notify_order_cancelled',
  });
  return true;
};

const expireUnpaidOrders = async ({ ttlMin = TTL_MIN(), limit = 50 } = {}) => {
  const rows = (await pool.query(
    `SELECT o.*, (SELECT merchant_txn_id FROM payments p WHERE p.order_id = o.id ORDER BY p.created_at DESC LIMIT 1) AS last_txn
     FROM orders o
     WHERE o.payment_method <> 'COD' AND o.payment_status <> 'Paid' AND o.status IN ('Pending','Processing')
       AND o.tracking_id IS NULL AND o.created_at < NOW() - ($1 * INTERVAL '1 minute')
     ORDER BY o.created_at LIMIT $2`, [ttlMin, limit])).rows;
  const out = { checked: rows.length, cancelled: 0, paid: 0, skipped: 0 };
  for (const o of rows) {
    try {
      if (o.last_txn) {
        const g = await gatewayStatus(o.last_txn);
        await pool.query('UPDATE payments SET status = $1, gateway_response = $2 WHERE merchant_txn_id = $3', [g.status, JSON.stringify(g.raw), o.last_txn]);
        if (g.status === 'SUCCESS') {
          await pool.query(`UPDATE orders SET payment_status = 'Paid' WHERE id = $1`, [o.id]);
          require('./shipmentService').onOrderPaid(o.id, 'expiry-check').catch(() => {});
          out.paid += 1; continue;
        }
      }
      if (await cancelUnpaid(o)) out.cancelled += 1; else out.skipped += 1;
    } catch (err) {
      out.skipped += 1; // gateway unreachable / not configured → never cancel on uncertainty
    }
  }
  if (out.cancelled || out.paid) console.log(`[payments] unpaid-order expiry: ${JSON.stringify(out)}`);
  return out;
};

module.exports = { expireUnpaidOrders, cancelUnpaid };
