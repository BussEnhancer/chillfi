// Store-owner-configurable cancellation/return policy (Admin → Settings → Cancellation & Returns).
// Both windows are optional: an empty/zero value means "no extra time limit" — cancellation still
// falls back to the shipment-pickup gate (shipmentService.CANCELLABLE) and returns still require
// a Delivered/Cancelled order, exactly as before this feature existed.
const { getSetting } = require('./settings');
const { CANCELLABLE } = require('../services/shipmentService');

const hoursToMs = (h) => h * 60 * 60 * 1000;
const daysToMs = (d) => d * 24 * 60 * 60 * 1000;

const getCancellationPolicy = async () => {
  const enabled = (await getSetting('cancellation_enabled')) !== 'false'; // default: on
  const windowHours = parseFloat(await getSetting('cancellation_window_hours'));
  return { enabled, windowHours: windowHours > 0 ? windowHours : null };
};

const getReturnPolicy = async () => {
  const enabled = (await getSetting('returns_enabled')) !== 'false'; // default: on
  const windowDays = parseFloat(await getSetting('return_window_days'));
  return { enabled, windowDays: windowDays > 0 ? windowDays : null };
};

/**
 * Computes what the customer is currently allowed to do with this order, for display (can_cancel,
 * can_return + deadlines) and so both web and app read the same server-decided answer instead of
 * re-deriving it from raw status. Does NOT throw — callers that need to enforce (not just display)
 * re-check at write time in cancelOrder/requestRefund, since eligibility here is TTL-cached policy
 * plus can go stale between the GET and the POST.
 */
const computeOrderEligibility = async (order) => {
  const [cancelPolicy, returnPolicy] = await Promise.all([getCancellationPolicy(), getReturnPolicy()]);

  let can_cancel = false;
  let cancel_deadline_at = null;
  if (cancelPolicy.enabled && order.status !== 'Delivered' && order.status !== 'Cancelled') {
    const shipmentOk = CANCELLABLE.includes(order.shipping_status || null);
    if (shipmentOk) {
      if (cancelPolicy.windowHours != null) {
        cancel_deadline_at = new Date(new Date(order.created_at).getTime() + hoursToMs(cancelPolicy.windowHours));
        can_cancel = Date.now() <= cancel_deadline_at.getTime();
      } else {
        can_cancel = true;
      }
    }
  }

  let can_return = false;
  let return_deadline_at = null;
  if (returnPolicy.enabled && ['Delivered', 'Cancelled'].includes(order.status)) {
    if (order.status === 'Cancelled') {
      can_return = order.payment_status === 'Paid'; // matches requestRefund's existing rule
    } else if (order.delivered_at && returnPolicy.windowDays != null) {
      return_deadline_at = new Date(new Date(order.delivered_at).getTime() + daysToMs(returnPolicy.windowDays));
      can_return = Date.now() <= return_deadline_at.getTime();
    } else {
      can_return = true;
    }
  }

  return {
    can_cancel,
    cancel_deadline_at: cancel_deadline_at ? cancel_deadline_at.toISOString() : null,
    can_return,
    return_deadline_at: return_deadline_at ? return_deadline_at.toISOString() : null,
  };
};

module.exports = { getCancellationPolicy, getReturnPolicy, computeOrderEligibility };
