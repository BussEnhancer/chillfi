// Opens a refund request for a paid, non-COD order (idempotent: never duplicates an open/finished one).
// Used when a paid order is cancelled, and when a payment arrives for an already-cancelled order.
const openAutoRefund = async (db, order, reason) => {
  if (order.payment_status !== 'Paid' || order.payment_method === 'COD') return false;
  const r = await db.query(
    `INSERT INTO refund_requests (order_id, user_id, type, reason, refund_amount)
     SELECT $1, $2, 'Refund', $3, $4
     WHERE NOT EXISTS (SELECT 1 FROM refund_requests WHERE order_id = $1 AND status IN ('Requested','Approved','Refunded'))
     RETURNING id`,
    [order.id, order.user_id, reason, order.total]
  );
  return r.rows.length > 0;
};

module.exports = { openAutoRefund };
