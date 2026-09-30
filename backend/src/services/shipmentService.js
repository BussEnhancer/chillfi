/**
 * Shipment lifecycle for ChillFi orders (Delhivery).
 *
 *   order placed ──► maybeAutoShip ──► createShipmentForOrder (atomic claim → Delhivery → AWB)
 *   Delhivery webhook / poller ──► applyCourierUpdate ──► orders + shipment_events ──► notifications
 *
 * Invariants:
 *   - one ChillFi order ⇒ at most one Delhivery shipment (DB claim + Delhivery duplicate-order recovery)
 *   - courier events are de-duplicated (shipment_events.dedupe_key) and never move an order backwards
 *     in time or out of a terminal state (delivered / rto_delivered / cancelled)
 *   - a shipping failure never rolls back or loses the order; it is marked 'failed' and retried
 */
const crypto = require('crypto');
const pool = require('../db/pool');
const delhivery = require('../utils/delhivery');
const { getSetting } = require('../utils/settings');
const { notifyUser } = require('../utils/notify');
const { mapDelhiveryStatus, isTerminal, rankOf, labelOf, NOTIFY } = require('../utils/shipmentStatus');
const { renderTemplate } = require('../utils/emailTemplates');

// shippingStatus → email-templates key (subject/body admin-editable in Settings → Email Templates)
const STATUS_TEMPLATE = {
  manifested: 'shipment_manifested', in_transit: 'order_shipped', out_for_delivery: 'order_out_for_delivery',
  delivered: 'order_delivered', rto_in_transit: 'shipment_returning', rto_delivered: 'order_returned', cancelled: 'shipment_cancelled',
};

const log = (msg) => console.log(`[shipping] ${msg}`);
const MAX_AUTO_ATTEMPTS = 5;
const CLAIM_STALE_MIN = 5;

const loadOrderForShipment = async (orderId) => {
  const r = await pool.query(`
    SELECT o.*, u.name AS customer_name, u.phone AS customer_phone, u.email AS customer_email,
           COALESCE(o.shipping_address->>'name', a.name) AS addr_name, COALESCE(o.shipping_address->>'phone', a.phone) AS addr_phone, COALESCE(o.shipping_address->>'line1', a.line1) AS line1, COALESCE(o.shipping_address->>'line2', a.line2) AS line2,
           COALESCE(o.shipping_address->>'city', a.city) AS city, COALESCE(o.shipping_address->>'state', a.state) AS state, COALESCE(o.shipping_address->>'pincode', a.pincode) AS pincode
    FROM orders o
    JOIN users u ON u.id = o.user_id
    LEFT JOIN addresses a ON a.id = o.address_id
    WHERE o.id = $1`, [orderId]);
  if (!r.rows.length) return null;
  const o = r.rows[0];
  const items = await pool.query('SELECT product_name AS name, quantity, price FROM order_items WHERE order_id = $1', [orderId]);
  return {
    ...o,
    items: items.rows,
    address: { name: o.addr_name, phone: o.addr_phone, line1: o.line1, line2: o.line2, city: o.city, state: o.state, pincode: o.pincode },
  };
};

const ineligibleReason = (o) => {
  if (!o) return 'Order not found';
  if (o.tracking_id) return `Shipment already created. AWB/Waybill: ${o.tracking_id}`;
  if (o.status !== 'Processing') return `Order is ${o.status}; only Processing orders can be shipped`;
  if (o.payment_method !== 'COD' && o.payment_status !== 'Paid') return `Prepaid order is not paid yet (payment ${o.payment_status})`;
  return null;
};

/**
 * Creates the Delhivery shipment for an order exactly once.
 * Returns { ok, awb, recovered?, reason?, error? }.
 */
const createShipmentForOrder = async (orderId, { trigger = 'auto' } = {}) => {
  const order = await loadOrderForShipment(orderId);
  const reason = ineligibleReason(order);
  if (reason) return { ok: false, reason, awb: order?.tracking_id || null };

  // Atomic claim: only one caller can move the order into 'creating'.
  const claim = await pool.query(`
    UPDATE orders SET shipping_status = 'creating', shipment_claimed_at = NOW(),
      shipment_attempts = COALESCE(shipment_attempts, 0) + 1, shipment_error = NULL, updated_at = NOW()
    WHERE id = $1 AND tracking_id IS NULL AND status = 'Processing'
      AND (shipping_status IS NULL OR shipping_status IN ('pending', 'failed')
           OR (shipping_status = 'creating' AND shipment_claimed_at < NOW() - ($2 || ' minutes')::interval))
    RETURNING shipment_attempts`, [orderId, String(CLAIM_STALE_MIN)]);
  if (!claim.rows.length) return { ok: false, reason: 'Shipment creation already in progress for this order' };

  log(`create start order=${order.order_number} trigger=${trigger} attempt=${claim.rows[0].shipment_attempts}`);
  try {
    const { waybill, env, recovered } = await delhivery.createShipment(order);
    await pool.query(`
      UPDATE orders SET tracking_id = $1, shipment_provider = 'delhivery', shipment_env = $2,
        shipping_status = 'manifested', courier_status = 'Manifested', courier_status_type = 'UD',
        courier_status_at = NULL, shipment_created_at = NOW(), shipment_error = NULL, updated_at = NOW()
      WHERE id = $3`, [waybill, env, orderId]);
    await recordEvent({
      orderId, awb: waybill, source: 'api', status: 'Manifested', statusType: 'UD', applied: true,
      eventTime: new Date(), instructions: recovered ? 'Existing Delhivery shipment re-linked' : 'Shipment created via API',
      dedupeKey: `${waybill}|created`,
    });
    log(`create ok order=${order.order_number} awb=${waybill} env=${env}${recovered ? ' (recovered existing)' : ''}`);
    await sendStatusNotification({ ...order, tracking_id: waybill }, 'manifested');
    ensurePickup({ trigger: `order ${order.order_number}` }); // non-blocking; retried by scheduler
    return { ok: true, awb: waybill, env, recovered };
  } catch (err) {
    const code = err.code || 'ERROR';
    await pool.query(
      `UPDATE orders SET shipping_status = 'failed', shipment_error = $1, updated_at = NOW() WHERE id = $2`,
      [`[${code}] ${err.message}`.slice(0, 1000), orderId]
    );
    log(`create FAILED order=${order.order_number} code=${code} retryable=${!!err.retryable}: ${err.message}`);
    return { ok: false, error: err.message, code };
  }
};

// ── Pickup scheduling ──────────────────────────────────────────────────────
// Delhivery collects parcels only against a pickup request. After shipments are created we make
// sure a request exists: same day if before the cut-off (IST), otherwise the next day.
//   DELHIVERY_AUTO_PICKUP   'true' | 'false'  (default true)
//   DELHIVERY_PICKUP_TIME   HH:MM  (default 14:00)   DELHIVERY_PICKUP_CUTOFF HH:MM (default 12:00)
const istNow = () => new Date(Date.now() + 5.5 * 3600e3); // fields read with getUTC* = IST wall clock
const pickupSlot = async () => {
  const time = ((await getSetting('DELHIVERY_PICKUP_TIME')) || '14:00').slice(0, 5);
  const cutoff = ((await getSetting('DELHIVERY_PICKUP_CUTOFF')) || '12:00').slice(0, 5);
  const now = istNow();
  const hhmm = now.toISOString().slice(11, 16);
  const day = new Date(now);
  if (hhmm >= cutoff) day.setUTCDate(day.getUTCDate() + 1);
  if (day.getUTCDay() === 0) day.setUTCDate(day.getUTCDate() + 1); // no Sunday pickups
  return { date: day.toISOString().slice(0, 10), time: `${time}:00` };
};

const ensurePickup = async ({ trigger = 'auto' } = {}) => {
  try {
    if ((await getSetting('DELHIVERY_AUTO_PICKUP')) === 'false' && trigger !== 'admin') return { skipped: 'auto-pickup disabled' };
    if (!(await delhivery.isConfigured())) return { skipped: 'not configured' };
    const env = await delhivery.getEnv();
    const slot = await pickupSlot();
    // Parcels waiting for collection with no (or a past) pickup booked
    const waiting = (await pool.query(`
      SELECT id FROM orders
      WHERE tracking_id IS NOT NULL AND COALESCE(shipment_provider, 'delhivery') = 'delhivery'
        AND COALESCE(shipment_env, $1) = $1 AND status <> 'Cancelled'
        AND shipping_status IN ('manifested', 'pickup_pending')
        AND (pickup_scheduled_for IS NULL OR pickup_scheduled_for < CURRENT_DATE)`, [env])).rows;
    if (!waiting.length && trigger !== 'admin') return { skipped: 'nothing waiting' };
    const r = await delhivery.requestPickup({ date: slot.date, time: slot.time, count: waiting.length });
    if (waiting.length) {
      await pool.query('UPDATE orders SET pickup_scheduled_for = $1, pickup_request_id = COALESCE($2, pickup_request_id) WHERE id = ANY($3::uuid[])',
        [r.date || slot.date, r.pickup_id ? String(r.pickup_id) : null, waiting.map((w) => w.id)]);
    }
    await require('../utils/settings').setSetting('DELHIVERY_LAST_PICKUP', JSON.stringify({ ...slot, ...r, count: waiting.length, at: new Date().toISOString() }));
    log(`pickup ${r.existing ? 'already booked' : `requested id=${r.pickup_id}`} for ${slot.date} ${slot.time} parcels=${waiting.length} (${trigger})`);
    return { ok: true, ...slot, ...r, count: waiting.length };
  } catch (err) {
    log(`pickup request FAILED (${trigger}): ${err.message}`);
    return { ok: false, error: err.message };
  }
};

// Fire-and-forget hook used after order placement / payment confirmation.
const maybeAutoShip = async (orderId, trigger) => {
  try {
    if ((await getSetting('DELHIVERY_AUTO_SHIP')) === 'false') return { skipped: 'auto-ship disabled' };
    if (!(await delhivery.isConfigured())) {
      log(`auto-ship skipped order=${orderId}: Delhivery not configured`);
      return { skipped: 'not configured' };
    }
    return await createShipmentForOrder(orderId, { trigger });
  } catch (err) {
    log(`auto-ship error order=${orderId}: ${err.message}`);
    return { ok: false, error: err.message };
  }
};

// ── Events & courier updates ───────────────────────────────────────────────
const shortHash = (s) => crypto.createHash('sha1').update(String(s || '')).digest('hex').slice(0, 10);

const recordEvent = async ({ orderId, awb, source, status, statusType, location, instructions, eventTime, applied = false, dedupeKey, raw }, client = pool) => {
  const r = await client.query(`
    INSERT INTO shipment_events (order_id, awb, source, status, status_type, location, instructions, event_time, applied, dedupe_key, raw)
    VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11)
    ON CONFLICT (dedupe_key) DO NOTHING RETURNING id`,
    [orderId, awb, source, status, statusType, location, instructions, eventTime, applied, dedupeKey, raw ? JSON.stringify(raw) : null]);
  return r.rows[0]?.id || null;
};

const eventKey = (u) => `${u.awb}|${u.status_type || ''}|${u.status || ''}|${u.status_time ? u.status_time.toISOString() : 'na'}|${shortHash(u.instructions)}`;

/**
 * Applies one normalized courier status (from webhook or poll) to the matching order.
 * Returns { matched, duplicate, applied, from, to, reason }.
 */
const applyCourierUpdate = async (u, { source, raw, applyState = true } = {}) => {
  if (!u?.awb) return { matched: false, reason: 'no AWB' };
  const client = await pool.connect();
  let result; let notifyOrder = null; let notifyState = null; let attemptFailed = false;
  try {
    await client.query('BEGIN');
    const ord = await client.query('SELECT * FROM orders WHERE tracking_id = $1 FOR UPDATE', [u.awb]);
    const order = ord.rows[0];
    const eventId = await recordEvent({
      orderId: order?.id || null, awb: u.awb, source, status: u.status, statusType: u.status_type,
      location: u.location, instructions: u.instructions, eventTime: u.status_time,
      // history-only scans get their own key space so they never shadow the status event itself
      dedupeKey: applyState ? eventKey(u) : `scan|${eventKey(u)}`, raw,
    }, client);

    if (!order) { await client.query('COMMIT'); log(`update for unknown AWB ${u.awb} (${source}) stored`); return { matched: false, reason: 'unknown AWB' }; }
    if (!eventId) { await client.query('COMMIT'); return { matched: true, duplicate: true }; }
    if (!applyState) { await client.query('COMMIT'); return { matched: true, applied: false, reason: 'history only' }; }

    const mapped = mapDelhiveryStatus(u.status_type, u.status);
    const from = order.shipping_status;
    const prevAt = order.courier_status_at ? new Date(order.courier_status_at) : null;
    let skip = null;
    if (!mapped) skip = `unmapped status ${u.status_type}/${u.status}`;
    else if (isTerminal(from) && mapped.shippingStatus !== from) skip = `order already ${from}`;
    // courier_status_at only ever holds courier-reported times; allow 60s for clock/rounding skew.
    else if (u.status_time && prevAt && u.status_time.getTime() < prevAt.getTime() - 60000) skip = 'older than current status (out-of-order)';
    else if (!u.status_time && rankOf(mapped.shippingStatus) < rankOf(from)) skip = 'undated regression';

    if (skip) {
      await client.query('COMMIT');
      log(`update awb=${u.awb} ${u.status_type}/${u.status} not applied: ${skip}`);
      return { matched: true, applied: false, reason: skip };
    }

    const to = mapped.shippingStatus;
    let newOrderStatus = order.status;
    if (mapped.orderStatus === 'Delivered') newOrderStatus = 'Delivered';
    else if (mapped.orderStatus && order.status !== 'Cancelled' && order.status !== 'Delivered') newOrderStatus = mapped.orderStatus;

    await client.query(`
      UPDATE orders SET shipping_status = $1::varchar, courier_status = $2, courier_status_type = $3,
        courier_status_at = COALESCE($4::timestamptz, NOW()), courier_location = COALESCE($5, courier_location),
        expected_delivery_date = COALESCE($6::timestamptz, expected_delivery_date), status = $7::varchar,
        delivered_at = CASE WHEN $1::varchar = 'delivered' THEN COALESCE($4::timestamptz, NOW()) ELSE delivered_at END,
        payment_status = CASE WHEN $1::varchar = 'delivered' AND payment_method = 'COD' THEN 'Paid' ELSE payment_status END,
        updated_at = NOW()
      WHERE id = $8`,
      [to, u.status, u.status_type, u.status_time, u.location, u.expected_delivery || null, newOrderStatus, order.id]);
    await client.query('UPDATE shipment_events SET applied = TRUE WHERE id = $1', [eventId]);
    await client.query('COMMIT');

    log(`update awb=${u.awb} order=${order.order_number} ${from || '-'} → ${to} (order ${order.status} → ${newOrderStatus}) via ${source}`);
    attemptFailed = from === 'out_for_delivery' && to === 'at_destination_hub';
    if (to !== from || attemptFailed) { notifyOrder = order; notifyState = to; }
    result = { matched: true, applied: true, from, to, orderStatus: newOrderStatus };
  } catch (err) {
    await client.query('ROLLBACK').catch(() => {});
    throw err;
  } finally {
    client.release();
  }

  if (notifyOrder) {
    if (attemptFailed) {
      const instructions = u.instructions ? ` (${u.instructions})` : '';
      const { subject, body } = await renderTemplate('delivery_attempt_failed', { order_number: notifyOrder.order_number, instructions });
      await notifyUser(notifyOrder.user_id, {
        title: subject, body,
        data: { order_id: notifyOrder.id, awb: u.awb, shipping_status: 'delivery_attempt_failed' },
        dedupeKey: `order:${notifyOrder.id}:attempt_failed:${u.status_time ? u.status_time.toISOString() : Date.now()}`,
        storeSettingKey: 'notify_order_shipped',
      });
    } else {
      await sendStatusNotification(notifyOrder, notifyState);
    }
  }
  return result;
};

const sendStatusNotification = async (order, shippingStatus) => {
  const n = NOTIFY[shippingStatus];
  if (!n) return null;
  const { subject, body } = await renderTemplate(STATUS_TEMPLATE[shippingStatus] || shippingStatus, {
    order_number: order.order_number, tracking_id: order.tracking_id || '',
  });
  return notifyUser(order.user_id, {
    title: subject, body,
    data: { order_id: order.id, order_number: order.order_number, awb: order.tracking_id || '', shipping_status: shippingStatus },
    dedupeKey: `order:${order.id}:${shippingStatus}`,
    storeSettingKey: n.pref,
  });
};

const notifyOrderConfirmed = async (order) => {
  const { subject, body } = await renderTemplate('order_confirmed', { order_number: order.order_number, total: order.total });
  const r = await notifyUser(order.user_id, {
    title: subject, body,
    data: { order_id: order.id, order_number: order.order_number },
    dedupeKey: `order:${order.id}:placed`,
    storeSettingKey: 'notify_order_placed',
  });
  // First confirmation only (same dedupe as the customer's notification) → tell the store.
  if (r.inserted) require('../utils/adminAlerts').newOrderAlert(order).catch(() => {});
  return r;
};

/** Called whenever an order transitions to payment_status = 'Paid' (any gateway path). */
const onOrderPaid = async (orderId, trigger) => {
  const o = (await pool.query('SELECT * FROM orders WHERE id = $1', [orderId])).rows[0];
  if (!o) return;
  console.log(`[order] paid ${o.order_number} via ${trigger}`);
  // Payment landed after the order was cancelled (customer cancelled, or unpaid-order expiry) → refund, never ship.
  if (o.status === 'Cancelled') {
    const opened = await require('../utils/refunds').openAutoRefund(pool, o, 'Payment received after the order was cancelled');
    if (opened) notifyUser(o.user_id, {
      title: 'Refund started',
      body: `We received a payment for cancelled order ${o.order_number}. A full refund of ₹${o.total} has been started.`,
      data: { order_id: o.id, order_number: o.order_number },
      dedupeKey: `order:${o.id}:late-payment-refund`,
    });
    return;
  }
  await notifyOrderConfirmed(o);
  if (o.payment_method !== 'COD') await maybeAutoShip(orderId, trigger);
};

// ── Pull sync (fallback to webhook) ────────────────────────────────────────
const syncShipments = async ({ orderIds = null, limit = 500 } = {}) => {
  if (!(await delhivery.isConfigured())) return { skipped: 'not configured' };
  const env = await delhivery.getEnv();
  const params = [env];
  let filter = `AND (o.shipping_status IS NULL OR o.shipping_status NOT IN ('delivered','rto_delivered','cancelled'))`;
  if (orderIds) { params.push(orderIds); filter = `AND o.id = ANY($${params.length}::uuid[])`; }
  params.push(limit);
  const rows = (await pool.query(`
    SELECT o.id, o.tracking_id FROM orders o
    WHERE o.tracking_id IS NOT NULL AND COALESCE(o.shipment_provider, 'delhivery') = 'delhivery'
      AND COALESCE(o.shipment_env, $1) = $1 ${filter}
    ORDER BY o.tracking_synced_at NULLS FIRST LIMIT $${params.length}`, params)).rows;

  const summary = { checked: 0, applied: 0, errors: 0 };
  for (let i = 0; i < rows.length; i += 50) {
    const batch = rows.slice(i, i + 50);
    try {
      const shipments = await delhivery.trackWaybills(batch.map((r) => r.tracking_id));
      for (const s of shipments) {
        for (const scan of [...s.scans].sort((a, b) => (a.time || 0) - (b.time || 0))) {
          await applyCourierUpdate({ awb: s.waybill, status: scan.status, status_type: scan.status_type, status_time: scan.time, location: scan.location, instructions: scan.instructions }, { source: 'poll', applyState: false });
        }
        const r = await applyCourierUpdate({ ...s, awb: s.waybill }, { source: 'poll' });
        summary.checked += 1;
        if (r.applied) summary.applied += 1;
      }
      await pool.query('UPDATE orders SET tracking_synced_at = NOW() WHERE id = ANY($1::uuid[])', [batch.map((r) => r.id)]);
    } catch (err) {
      summary.errors += 1;
      log(`sync batch failed: ${err.message}`);
    }
  }
  return summary;
};

// Retries orders whose automatic shipment creation failed (transient API/network issues).
// Legacy orders (shipping_status NULL) are never auto-shipped — only orders created by this flow.
const retryFailedShipments = async () => {
  if ((await getSetting('DELHIVERY_AUTO_SHIP')) === 'false' || !(await delhivery.isConfigured())) return { skipped: true };
  const rows = (await pool.query(`
    SELECT id FROM orders
    WHERE tracking_id IS NULL AND status = 'Processing'
      AND (payment_method = 'COD' OR payment_status = 'Paid')
      AND (shipping_status IN ('pending', 'failed')
           -- a restart/crash mid-creation leaves 'creating' behind; reclaim once the claim is stale
           OR (shipping_status = 'creating' AND shipment_claimed_at < NOW() - INTERVAL '${CLAIM_STALE_MIN} minutes'))
      AND COALESCE(shipment_attempts, 0) < $1
      AND COALESCE(shipment_error, '') NOT LIKE '[INVALID_ADDRESS]%'
      AND COALESCE(shipment_claimed_at, created_at) < NOW() - INTERVAL '10 minutes'
    ORDER BY created_at LIMIT 50`, [MAX_AUTO_ATTEMPTS])).rows;
  let ok = 0;
  for (const r of rows) if ((await createShipmentForOrder(r.id, { trigger: 'retry' })).ok) ok += 1;
  return { retried: rows.length, ok };
};

let timer = null; let running = false;
const lastRun = { at: null, result: null };
const runScheduledSync = async () => {
  if (running) return;
  running = true;
  try {
    const retry = await retryFailedShipments();
    const sync = await syncShipments();
    const pickup = await ensurePickup({ trigger: 'scheduler' });
    await require('./paymentExpiry').expireUnpaidOrders().catch((e) => log(`unpaid-order expiry error: ${e.message}`));
    lastRun.at = new Date(); lastRun.result = { retry, sync, pickup };
    if (sync.checked || retry.retried) log(`scheduled sync: ${JSON.stringify(lastRun.result)}`);
  } catch (err) {
    log(`scheduled sync error: ${err.message}`);
  } finally { running = false; }
};
const startScheduler = () => {
  const minutes = parseFloat(process.env.DELHIVERY_SYNC_INTERVAL_MIN || '30');
  if (!(minutes > 0) || timer) return;
  // pm2 cluster mode runs several instances; only the first one polls Delhivery.
  if (process.env.NODE_APP_INSTANCE && process.env.NODE_APP_INSTANCE !== '0') return;
  timer = setInterval(runScheduledSync, minutes * 60 * 1000);
  timer.unref?.();
  log(`tracking sync scheduler every ${minutes} min`);
};

// ── Cancellation ────────────────────────────────────────────────────────────
// Statuses in which Delhivery accepts a cancel (per docs) map to these ChillFi states.
const CANCELLABLE = [null, 'pending', 'failed', 'creating', 'manifested', 'pickup_pending'];

/** Cancels the courier shipment (if any) before an order is cancelled. Throws with .status on refusal. */
const cancelShipmentForOrder = async (order, { by = 'customer' } = {}) => {
  if (!order.tracking_id || (order.shipment_provider || 'delhivery') !== 'delhivery') return { cancelled: false, reason: 'no shipment' };
  if (order.shipping_status === 'cancelled') return { cancelled: true, reason: 'already cancelled' };
  if (!CANCELLABLE.includes(order.shipping_status || null)) {
    const e = new Error(`Order has already been picked up by the courier (${labelOf(order.shipping_status)}); it can no longer be cancelled. Please contact support.`);
    e.status = 409;
    throw e;
  }
  try {
    const r = await delhivery.cancelShipment(order.tracking_id);
    await pool.query(`UPDATE orders SET shipping_status = 'cancelled', courier_status = 'Cancelled', updated_at = NOW() WHERE id = $1`, [order.id]);
    await recordEvent({ orderId: order.id, awb: order.tracking_id, source: by === 'admin' ? 'admin' : 'api', status: 'Cancelled', statusType: 'CN', eventTime: new Date(), applied: true, instructions: `Cancelled by ${by}${r.remark ? `: ${r.remark}` : ''}`, dedupeKey: `${order.tracking_id}|cancel` });
    log(`cancel ok order=${order.order_number} awb=${order.tracking_id} by=${by}`);
    return { cancelled: true };
  } catch (err) {
    log(`cancel FAILED order=${order.order_number} awb=${order.tracking_id}: ${err.message}`);
    const e = new Error(`Could not cancel the courier shipment: ${err.message}`);
    e.status = 502;
    throw e;
  }
};

// ── Read model for customer/admin tracking views ────────────────────────────
const STALE_MS = 10 * 60 * 1000;
const getTrackingView = async (orderId, { refresh = true } = {}) => {
  let o = (await pool.query('SELECT * FROM orders WHERE id = $1', [orderId])).rows[0];
  if (!o || !o.tracking_id) return null;
  let stale = false;
  const due = !o.tracking_synced_at || Date.now() - new Date(o.tracking_synced_at).getTime() > STALE_MS;
  if (refresh && due && !isTerminal(o.shipping_status) && (o.shipment_provider || 'delhivery') === 'delhivery') {
    const r = await syncShipments({ orderIds: [orderId] }).catch((e) => ({ errors: 1, e }));
    stale = !!(r.errors || r.skipped);
    o = (await pool.query('SELECT * FROM orders WHERE id = $1', [orderId])).rows[0];
  }
  const events = (await pool.query(`
    SELECT status, status_type, location, instructions, event_time, source FROM shipment_events
    WHERE order_id = $1 ORDER BY event_time DESC NULLS LAST, created_at DESC`, [orderId])).rows;
  // Collapse identical scan/status pairs reported by both webhook and poll, and hide our own
  // "shipment created" marker once Delhivery has reported its own Manifested scan.
  const courierManifested = events.some((e) => e.source !== 'api' && /^manifested$/i.test(e.status || ''));
  const seen = new Set();
  const scans = events.filter((e) => {
    if (courierManifested && e.source === 'api' && /^manifested$/i.test(e.status || '')) return false;
    const k = `${e.status_type}|${e.status}|${e.event_time?.toISOString?.()}|${e.instructions}`;
    if (seen.has(k)) return false; seen.add(k); return true;
  }).map((e) => ({ status: e.status, location: e.location, instructions: e.instructions, time: e.event_time }));
  return {
    waybill: o.tracking_id,
    provider: o.shipment_provider || 'delhivery',
    env: o.shipment_env,
    status: o.courier_status || labelOf(o.shipping_status),
    shipping_status: o.shipping_status,
    shipping_status_label: labelOf(o.shipping_status),
    order_status: o.status,
    location: o.courier_location,
    expected_delivery: o.expected_delivery_date,
    last_update: o.courier_status_at,
    synced_at: o.tracking_synced_at,
    stale,
    scans,
  };
};

module.exports = {
  createShipmentForOrder, maybeAutoShip, applyCourierUpdate, syncShipments, retryFailedShipments,
  runScheduledSync, startScheduler, lastRun, cancelShipmentForOrder, getTrackingView, sendStatusNotification,
  loadOrderForShipment, notifyOrderConfirmed, onOrderPaid, ensurePickup, CANCELLABLE,
};
