const crypto = require('crypto');
const axios = require('axios');
const pool = require('../db/pool');

// Local-only payment simulation. Requires BOTH NODE_ENV=development AND PAYMENT_DEV_AUTOPAY=true, so a
// missing/unknown NODE_ENV (e.g. a staging box) can never mark orders as paid without PhonePe confirming.
const DEV_AUTOPAY = process.env.NODE_ENV === 'development' && process.env.PAYMENT_DEV_AUTOPAY === 'true';
const { onOrderPaid } = require('../services/shipmentService');
const phonepe = require('../utils/phonepe');

// POST /api/payment/initiate  (PhonePe)
const initiatePayment = async (req, res) => {
  const { order_id } = req.body;
  if (!order_id) return res.status(400).json({ success: false, message: 'order_id required' });

  // The amount always comes from the order record — never from the client (the app sends only
  // order_id, and a client-supplied amount could be tampered with).
  const ord = await pool.query('SELECT total, payment_status, status FROM orders WHERE id = $1 AND user_id = $2', [order_id, req.user.id]);
  if (!ord.rows.length) return res.status(404).json({ success: false, message: 'Order not found' });
  if (ord.rows[0].payment_status === 'Paid') return res.status(400).json({ success: false, message: 'Order is already paid' });
  if (ord.rows[0].status === 'Cancelled') return res.status(400).json({ success: false, message: 'Order is cancelled' });
  const amount = parseFloat(ord.rows[0].total);

  const cfg = await phonepe.getConfig();
  const merchantTxnId = `CF_${order_id.replace(/-/g, '').slice(0, 10)}_${Date.now()}`;
  const payload = {
    merchantId: cfg.merchantId,
    merchantTransactionId: merchantTxnId,
    merchantUserId: `USER_${req.user.id.replace(/-/g, '').slice(0, 10)}`,
    amount: Math.round(parseFloat(amount) * 100), // in paise
    redirectUrl: `${process.env.APP_BASE_URL}/api/payment/callback`,
    redirectMode: 'REDIRECT',
    callbackUrl: `${process.env.APP_BASE_URL}/api/payment/webhook`,
    mobileNumber: req.user.phone,
    paymentInstrument: { type: 'PAY_PAGE' },
  };

  const base64Payload = Buffer.from(JSON.stringify(payload)).toString('base64');
  const checksum = phonepe.xVerify(cfg, `${base64Payload}/pg/v1/pay`);

  // Log payment record
  await pool.query(
    'INSERT INTO payments (order_id, merchant_txn_id, amount, status) VALUES ($1,$2,$3,$4)',
    [order_id, merchantTxnId, amount, 'Pending']
  );

  // Development mode: return mock payment URL
  if (DEV_AUTOPAY) {
    return res.json({
      success: true,
      data: {
        merchant_txn_id: merchantTxnId,
        payment_url: `${process.env.APP_BASE_URL}/api/payment/dev-success?txn=${merchantTxnId}&order=${order_id}${req.headers.origin ? '&redirect=web' : ''}`,
      },
    });
  }

  const missing = phonepe.configProblems(cfg);
  if (missing.length) {
    console.error(`[payment] PhonePe ${cfg.env} not configured: ${missing.join(', ')}`);
    return res.status(503).json({ success: false, message: 'Online payment is temporarily unavailable' });
  }
  try {
    const response = await axios.post(
      `${cfg.baseUrl}/pg/v1/pay`,
      { request: base64Payload },
      { headers: { 'Content-Type': 'application/json', 'X-VERIFY': checksum } }
    );

    res.json({
      success: true,
      data: {
        merchant_txn_id: merchantTxnId,
        payment_url: response.data?.data?.instrumentResponse?.redirectInfo?.url,
      },
    });
  } catch (err) {
    console.error(`[payment] PhonePe ${cfg.env} initiate failed: ${err.response?.status || ''} ${err.response?.data?.code || err.message}`);
    res.status(500).json({ success: false, message: 'Payment initiation failed' });
  }
};

// POST /api/payment/verify
const verifyPayment = async (req, res) => {
  const { order_id } = req.body;
  let { merchant_txn_id } = req.body;
  if (!order_id) return res.status(400).json({ success: false, message: 'order ID required' });

  // Verify the order belongs to the requesting user
  const orderCheck = await pool.query(
    'SELECT id FROM orders WHERE id = $1 AND user_id = $2',
    [order_id, req.user.id]
  );
  if (!orderCheck.rows.length) {
    return res.status(403).json({ success: false, message: 'Order not found' });
  }

  // The mobile app sends only order_id — use this order's latest payment attempt.
  if (!merchant_txn_id) {
    const last = await pool.query('SELECT merchant_txn_id FROM payments WHERE order_id = $1 ORDER BY created_at DESC LIMIT 1', [order_id]);
    merchant_txn_id = last.rows[0]?.merchant_txn_id;
    if (!merchant_txn_id) return res.status(400).json({ success: false, message: 'No payment was started for this order' });
  } else {
    const own = await pool.query('SELECT 1 FROM payments WHERE merchant_txn_id = $1 AND order_id = $2', [merchant_txn_id, order_id]);
    if (!own.rows.length) return res.status(400).json({ success: false, message: 'Transaction does not belong to this order' });
  }

  // Dev shortcut
  if (DEV_AUTOPAY) {
    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      await client.query(`UPDATE payments SET status = 'SUCCESS' WHERE merchant_txn_id = $1`, [merchant_txn_id]);
      await client.query(`UPDATE orders SET payment_status = 'Paid' WHERE id = $1`, [order_id]);
      await client.query('COMMIT');
    } catch (e) {
      await client.query('ROLLBACK');
      throw e;
    } finally {
      client.release();
    }
    onOrderPaid(order_id, 'verify-dev').catch(() => {});
    return res.json({ success: true, message: 'Payment verified (dev mode)', data: { status: 'SUCCESS' } });
  }

  const cfg = await phonepe.getConfig();
  const checksum = phonepe.xVerify(cfg, `/pg/v1/status/${cfg.merchantId}/${merchant_txn_id}`);

  try {
    const response = await axios.get(
      `${cfg.baseUrl}/pg/v1/status/${cfg.merchantId}/${merchant_txn_id}`,
      { headers: { 'X-VERIFY': checksum, 'X-MERCHANT-ID': cfg.merchantId } }
    );

    const txnStatus = response.data?.data?.state;
    const pgStatus = txnStatus === 'COMPLETED' ? 'SUCCESS' : txnStatus === 'FAILED' ? 'FAILED' : 'PENDING';

    const client = await pool.connect();
    try {
      await client.query('BEGIN');
      await client.query(
        `UPDATE payments SET status = $1, gateway_response = $2 WHERE merchant_txn_id = $3`,
        [pgStatus, JSON.stringify(response.data), merchant_txn_id]
      );
      if (pgStatus === 'SUCCESS') {
        await client.query(`UPDATE orders SET payment_status = 'Paid' WHERE id = $1`, [order_id]);
      }
      await client.query('COMMIT');
    } catch (e) {
      await client.query('ROLLBACK');
      throw e;
    } finally {
      client.release();
    }

    if (pgStatus === 'SUCCESS') onOrderPaid(order_id, 'verify').catch(() => {});
    res.json({ success: true, data: { status: pgStatus } });
  } catch {
    res.status(500).json({ success: false, message: 'Verification failed' });
  }
};

// POST /api/payment/cod-confirm
const confirmCOD = async (req, res) => {
  const { order_id } = req.body;
  if (!order_id) return res.status(400).json({ success: false, message: 'order_id required' });

  // Confirmation only — never converts a prepaid/paid order to COD or revives a cancelled/shipped one.
  const r = await pool.query('SELECT payment_method, status FROM orders WHERE id = $1 AND user_id = $2', [order_id, req.user.id]);
  if (!r.rows.length) return res.status(404).json({ success: false, message: 'Order not found' });
  if (r.rows[0].payment_method !== 'COD') {
    return res.status(400).json({ success: false, message: 'This order was not placed as Cash on Delivery' });
  }
  res.json({ success: true, message: 'COD order confirmed', data: { status: r.rows[0].status } });
};

// POST /api/payment/webhook  (PhonePe server → server callback)
const webhook = async (req, res) => {
  try {
    const xVerify = req.headers['x-verify'];
    const { response } = req.body;
    if (!xVerify || !response) return res.status(400).json({ success: false });

    // Verify SHA256 checksum: SHA256(response + saltKey) + "###" + saltIndex
    const expected = phonepe.xVerify(await phonepe.getConfig(), response);
    const a = Buffer.from(String(xVerify)); const b = Buffer.from(expected);
    if (a.length !== b.length || !crypto.timingSafeEqual(a, b)) {
      console.warn('[webhook] Invalid X-VERIFY from PhonePe');
      return res.status(403).json({ success: false });
    }

    const decoded = JSON.parse(Buffer.from(response, 'base64').toString());
    const { merchantTransactionId, state } = decoded.data || {};

    if (merchantTransactionId && state) {
      const pgStatus = state === 'COMPLETED' ? 'SUCCESS' : 'FAILED';
      let paidOrderId = null;
      const client = await pool.connect();
      try {
        await client.query('BEGIN');
        await client.query(
          `UPDATE payments SET status = $1, gateway_response = $2 WHERE merchant_txn_id = $3`,
          [pgStatus, JSON.stringify(decoded), merchantTransactionId]
        );
        if (pgStatus === 'SUCCESS') {
          const payment = await client.query(
            `SELECT order_id FROM payments WHERE merchant_txn_id = $1`, [merchantTransactionId]
          );
          if (payment.rows.length) {
            await client.query(`UPDATE orders SET payment_status = 'Paid' WHERE id = $1`, [payment.rows[0].order_id]);
            paidOrderId = payment.rows[0].order_id;
          }
        }
        await client.query('COMMIT');
        if (paidOrderId) onOrderPaid(paidOrderId, 'phonepe-webhook').catch(() => {});
      } catch (e) {
        await client.query('ROLLBACK');
        throw e;
      } finally {
        client.release();
      }
    }
    res.json({ success: true });
  } catch {
    res.status(200).json({ success: false });
  }
};

// GET /api/payment/callback  — PhonePe redirects here after payment
const paymentCallback = async (req, res) => {
  const websiteUrl = process.env.WEBSITE_URL || process.env.FRONTEND_URL || 'http://localhost:5173';
  const { merchantTransactionId } = req.query;

  if (!merchantTransactionId) {
    return res.redirect(`${websiteUrl}/order-failed?reason=Missing+transaction+ID`);
  }

  try {
    // Look up order from payments table
    const pmtRow = await pool.query(
      `SELECT order_id FROM payments WHERE merchant_txn_id = $1`, [merchantTransactionId]
    );
    const orderId = pmtRow.rows[0]?.order_id;

    // Dev shortcut
    if (DEV_AUTOPAY) {
      if (orderId) {
        await pool.query(`UPDATE payments SET status = 'SUCCESS' WHERE merchant_txn_id = $1`, [merchantTransactionId]);
        await pool.query(`UPDATE orders SET payment_status = 'Paid' WHERE id = $1`, [orderId]);
        onOrderPaid(orderId, 'callback-dev').catch(() => {});
        const orderRow = await pool.query(`SELECT order_number, total FROM orders WHERE id = $1`, [orderId]);
        const o = orderRow.rows[0];
        return res.redirect(`${websiteUrl}/order-success?order_number=${o?.order_number || ''}&total=${o?.total || 0}`);
      }
      return res.redirect(`${websiteUrl}/order-failed?reason=Order+not+found`);
    }

    // Production: verify with PhonePe
    const cfg = await phonepe.getConfig();
    const checksum = phonepe.xVerify(cfg, `/pg/v1/status/${cfg.merchantId}/${merchantTransactionId}`);

    const response = await axios.get(
      `${cfg.baseUrl}/pg/v1/status/${cfg.merchantId}/${merchantTransactionId}`,
      { headers: { 'X-VERIFY': checksum, 'X-MERCHANT-ID': cfg.merchantId } }
    );

    const txnState = response.data?.data?.state;
    const pgStatus = txnState === 'COMPLETED' ? 'SUCCESS' : 'FAILED';

    await pool.query(
      `UPDATE payments SET status = $1, gateway_response = $2 WHERE merchant_txn_id = $3`,
      [pgStatus, JSON.stringify(response.data), merchantTransactionId]
    );

    if (pgStatus === 'SUCCESS' && orderId) {
      await pool.query(`UPDATE orders SET payment_status = 'Paid' WHERE id = $1`, [orderId]);
      onOrderPaid(orderId, 'callback').catch(() => {});
      const orderRow = await pool.query(`SELECT order_number, total FROM orders WHERE id = $1`, [orderId]);
      const o = orderRow.rows[0];
      return res.redirect(`${websiteUrl}/order-success?order_number=${o?.order_number || ''}&total=${o?.total || 0}`);
    }

    return res.redirect(`${websiteUrl}/order-failed?reason=Payment+${pgStatus.toLowerCase()}`);
  } catch (err) {
    console.error('[callback] error:', err.message);
    return res.redirect(`${websiteUrl}/order-failed?reason=Verification+error`);
  }
};

// GET /api/payment/dev-success (dev only)
const devSuccess = async (req, res) => {
  const { txn, order } = req.query;
  if (txn && order) {
    await pool.query(`UPDATE payments SET status = 'SUCCESS' WHERE merchant_txn_id = $1`, [txn]);
    await pool.query(`UPDATE orders SET payment_status = 'Paid' WHERE id = $1`, [order]);
    onOrderPaid(order, 'dev-success').catch(() => {});
  }
  if (req.query.redirect === 'web' && order) {
    const websiteUrl = process.env.WEBSITE_URL || process.env.FRONTEND_URL || 'http://localhost:5200';
    const o = (await pool.query('SELECT order_number, total FROM orders WHERE id = $1', [order])).rows[0];
    return res.redirect(`${websiteUrl}/order-success?order_number=${o?.order_number || ''}&total=${o?.total || 0}`);
  }
  res.send('<h2>✅ Dev Payment Success! Go back to the app.</h2>');
};

module.exports = {
  DEV_AUTOPAY, initiatePayment, verifyPayment, confirmCOD, webhook, paymentCallback, devSuccess };
