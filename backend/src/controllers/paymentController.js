const crypto = require('crypto');
const axios = require('axios');
const pool = require('../db/pool');

// POST /api/payment/initiate  (PhonePe)
const initiatePayment = async (req, res) => {
  const { order_id, amount } = req.body;
  if (!order_id || !amount) {
    return res.status(400).json({ success: false, message: 'order_id and amount required' });
  }

  const merchantTxnId = `CF_${order_id.replace(/-/g, '').slice(0, 10)}_${Date.now()}`;
  const payload = {
    merchantId: process.env.PHONEPE_MERCHANT_ID,
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
  const checksum = crypto
    .createHash('sha256')
    .update(`${base64Payload}/pg/v1/pay${process.env.PHONEPE_SALT_KEY}`)
    .digest('hex') + `###${process.env.PHONEPE_SALT_INDEX}`;

  // Log payment record
  await pool.query(
    'INSERT INTO payments (order_id, merchant_txn_id, amount, status) VALUES ($1,$2,$3,$4)',
    [order_id, merchantTxnId, amount, 'Pending']
  );

  // Development mode: return mock payment URL
  if (process.env.NODE_ENV === 'development') {
    return res.json({
      success: true,
      data: {
        merchant_txn_id: merchantTxnId,
        payment_url: `${process.env.APP_BASE_URL}/api/payment/dev-success?txn=${merchantTxnId}&order=${order_id}`,
      },
    });
  }

  try {
    const response = await axios.post(
      `${process.env.PHONEPE_BASE_URL}/pg/v1/pay`,
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
    res.status(500).json({ success: false, message: 'Payment initiation failed' });
  }
};

// POST /api/payment/verify
const verifyPayment = async (req, res) => {
  const { merchant_txn_id, order_id } = req.body;
  if (!merchant_txn_id) return res.status(400).json({ success: false, message: 'Transaction ID required' });

  // Dev shortcut
  if (process.env.NODE_ENV === 'development') {
    await pool.query(
      `UPDATE payments SET status = 'SUCCESS' WHERE merchant_txn_id = $1`,
      [merchant_txn_id]
    );
    await pool.query(
      `UPDATE orders SET payment_status = 'Paid' WHERE id = $1`,
      [order_id]
    );
    return res.json({ success: true, message: 'Payment verified (dev mode)', data: { status: 'SUCCESS' } });
  }

  const checksum = crypto
    .createHash('sha256')
    .update(`/pg/v1/status/${process.env.PHONEPE_MERCHANT_ID}/${merchant_txn_id}${process.env.PHONEPE_SALT_KEY}`)
    .digest('hex') + `###${process.env.PHONEPE_SALT_INDEX}`;

  try {
    const response = await axios.get(
      `${process.env.PHONEPE_BASE_URL}/pg/v1/status/${process.env.PHONEPE_MERCHANT_ID}/${merchant_txn_id}`,
      { headers: { 'X-VERIFY': checksum, 'X-MERCHANT-ID': process.env.PHONEPE_MERCHANT_ID } }
    );

    const txnStatus = response.data?.data?.state;
    const pgStatus = txnStatus === 'COMPLETED' ? 'SUCCESS' : txnStatus === 'FAILED' ? 'FAILED' : 'PENDING';

    await pool.query(
      `UPDATE payments SET status = $1, gateway_response = $2 WHERE merchant_txn_id = $3`,
      [pgStatus, JSON.stringify(response.data), merchant_txn_id]
    );

    if (pgStatus === 'SUCCESS') {
      await pool.query(`UPDATE orders SET payment_status = 'Paid' WHERE id = $1`, [order_id]);
    }

    res.json({ success: true, data: { status: pgStatus } });
  } catch {
    res.status(500).json({ success: false, message: 'Verification failed' });
  }
};

// POST /api/payment/cod-confirm
const confirmCOD = async (req, res) => {
  const { order_id } = req.body;
  if (!order_id) return res.status(400).json({ success: false, message: 'order_id required' });

  await pool.query(
    `UPDATE orders SET payment_method = 'COD', payment_status = 'Pending', status = 'Processing' WHERE id = $1 AND user_id = $2`,
    [order_id, req.user.id]
  );

  res.json({ success: true, message: 'COD order confirmed' });
};

// POST /api/payment/webhook  (PhonePe server → server callback)
const webhook = async (req, res) => {
  try {
    const xVerify = req.headers['x-verify'];
    const { response } = req.body;
    if (!xVerify || !response) return res.status(400).json({ success: false });

    // Verify SHA256 checksum: SHA256(response + saltKey) + "###" + saltIndex
    const expected =
      crypto.createHash('sha256').update(response + process.env.PHONEPE_SALT_KEY).digest('hex') +
      `###${process.env.PHONEPE_SALT_INDEX}`;
    if (xVerify !== expected) {
      console.warn('[webhook] Invalid X-VERIFY from PhonePe');
      return res.status(403).json({ success: false });
    }

    const decoded = JSON.parse(Buffer.from(response, 'base64').toString());
    const { merchantTransactionId, state } = decoded.data || {};

    if (merchantTransactionId && state) {
      const pgStatus = state === 'COMPLETED' ? 'SUCCESS' : 'FAILED';
      await pool.query(
        `UPDATE payments SET status = $1, gateway_response = $2 WHERE merchant_txn_id = $3`,
        [pgStatus, JSON.stringify(decoded), merchantTransactionId]
      );
      if (pgStatus === 'SUCCESS') {
        const payment = await pool.query(
          `SELECT order_id FROM payments WHERE merchant_txn_id = $1`, [merchantTransactionId]
        );
        if (payment.rows.length) {
          await pool.query(`UPDATE orders SET payment_status = 'Paid' WHERE id = $1`, [payment.rows[0].order_id]);
        }
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
    if (process.env.NODE_ENV !== 'production') {
      if (orderId) {
        await pool.query(`UPDATE payments SET status = 'SUCCESS' WHERE merchant_txn_id = $1`, [merchantTransactionId]);
        await pool.query(`UPDATE orders SET payment_status = 'Paid' WHERE id = $1`, [orderId]);
        const orderRow = await pool.query(`SELECT order_number, total FROM orders WHERE id = $1`, [orderId]);
        const o = orderRow.rows[0];
        return res.redirect(`${websiteUrl}/order-success?order_number=${o?.order_number || ''}&total=${o?.total || 0}`);
      }
      return res.redirect(`${websiteUrl}/order-failed?reason=Order+not+found`);
    }

    // Production: verify with PhonePe
    const checksum = crypto
      .createHash('sha256')
      .update(`/pg/v1/status/${process.env.PHONEPE_MERCHANT_ID}/${merchantTransactionId}${process.env.PHONEPE_SALT_KEY}`)
      .digest('hex') + `###${process.env.PHONEPE_SALT_INDEX}`;

    const response = await axios.get(
      `${process.env.PHONEPE_BASE_URL}/pg/v1/status/${process.env.PHONEPE_MERCHANT_ID}/${merchantTransactionId}`,
      { headers: { 'X-VERIFY': checksum, 'X-MERCHANT-ID': process.env.PHONEPE_MERCHANT_ID } }
    );

    const txnState = response.data?.data?.state;
    const pgStatus = txnState === 'COMPLETED' ? 'SUCCESS' : 'FAILED';

    await pool.query(
      `UPDATE payments SET status = $1, gateway_response = $2 WHERE merchant_txn_id = $3`,
      [pgStatus, JSON.stringify(response.data), merchantTransactionId]
    );

    if (pgStatus === 'SUCCESS' && orderId) {
      await pool.query(`UPDATE orders SET payment_status = 'Paid' WHERE id = $1`, [orderId]);
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
  }
  res.send('<h2>✅ Dev Payment Success! Go back to the app.</h2>');
};

module.exports = { initiatePayment, verifyPayment, confirmCOD, webhook, paymentCallback, devSuccess };
