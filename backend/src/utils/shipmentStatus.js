/**
 * Maps Delhivery (StatusType, Status) pairs to ChillFi states.
 * Source: Delhivery docs → "Pre-paid and COD shipments" (forward + RTO flow).
 *
 *   UD Manifested  – soft data received                  → manifested
 *   UD Not Picked  – not yet picked from warehouse       → pickup_pending
 *   UD In Transit  – picked up, moving to destination DC → in_transit        (order: Shipped)
 *   UD Pending     – reached destination DC              → at_destination_hub (order: Shipped)
 *   UD Dispatched  – out for delivery                    → out_for_delivery  (order: Shipped)
 *   DL Delivered   – accepted by customer                → delivered         (order: Delivered)
 *   RT In Transit / Pending / Dispatched                 → rto_in_transit    (order: Shipped)
 *   DL RTO         – returned to origin                  → rto_delivered     (order: Cancelled)
 *   CN *           – cancelled                           → cancelled
 *
 * Anything else is recorded as an event but never changes order state.
 * Docs explicitly warn not to hardcode the happy-path flow, so unknown combos are safe no-ops.
 */

// rank: forward progress. Terminal states can never be left by a courier event.
const STATES = {
  pending:            { rank: 0,  label: 'Awaiting shipment' },
  creating:           { rank: 0,  label: 'Creating shipment' },
  failed:             { rank: 0,  label: 'Shipment creation failed' },
  manifested:         { rank: 10, label: 'Shipment created' },
  pickup_pending:     { rank: 15, label: 'Awaiting pickup' },
  in_transit:         { rank: 20, label: 'In transit' },
  at_destination_hub: { rank: 30, label: 'Reached delivery hub' },
  out_for_delivery:   { rank: 40, label: 'Out for delivery' },
  rto_in_transit:     { rank: 50, label: 'Returning to seller' },
  delivered:          { rank: 100, label: 'Delivered', terminal: true },
  rto_delivered:      { rank: 100, label: 'Returned to seller', terminal: true },
  cancelled:          { rank: 100, label: 'Shipment cancelled', terminal: true },
};

const norm = (s) => String(s || '').toLowerCase().replace(/[^a-z]/g, '');

const mapDelhiveryStatus = (statusType, status) => {
  const t = String(statusType || '').toUpperCase();
  const s = norm(status);

  if (t === 'UD') {
    if (s === 'manifested') return { shippingStatus: 'manifested', orderStatus: null };
    if (s === 'notpicked') return { shippingStatus: 'pickup_pending', orderStatus: null };
    if (s === 'intransit') return { shippingStatus: 'in_transit', orderStatus: 'Shipped' };
    if (s === 'pending') return { shippingStatus: 'at_destination_hub', orderStatus: 'Shipped' };
    if (s === 'dispatched') return { shippingStatus: 'out_for_delivery', orderStatus: 'Shipped' };
  }
  if (t === 'DL') {
    if (s === 'delivered') return { shippingStatus: 'delivered', orderStatus: 'Delivered' };
    if (s === 'rto') return { shippingStatus: 'rto_delivered', orderStatus: 'Cancelled' };
  }
  if (t === 'RT' && ['intransit', 'pending', 'dispatched'].includes(s)) {
    return { shippingStatus: 'rto_in_transit', orderStatus: 'Shipped' };
  }
  if (t === 'CN') return { shippingStatus: 'cancelled', orderStatus: null };
  return null; // unknown → record only
};

const isTerminal = (shippingStatus) => !!STATES[shippingStatus]?.terminal;
const rankOf = (shippingStatus) => STATES[shippingStatus]?.rank ?? -1;
const labelOf = (shippingStatus) => STATES[shippingStatus]?.label || shippingStatus || null;

// Customer-facing notification copy per shipping state (null = no notification).
const NOTIFY = {
  manifested:       { title: 'Shipment created', body: (o) => `Your order ${o.order_number} is packed and handed to Delhivery. AWB: ${o.tracking_id}`, pref: 'notify_order_shipped' },
  in_transit:       { title: 'Order shipped', body: (o) => `Your order ${o.order_number} has been picked up and is on its way.`, pref: 'notify_order_shipped' },
  out_for_delivery: { title: 'Out for delivery', body: (o) => `Your order ${o.order_number} is out for delivery today.`, pref: 'notify_order_shipped' },
  delivered:        { title: 'Order delivered', body: (o) => `Your order ${o.order_number} has been delivered. Enjoy!`, pref: 'notify_order_delivered' },
  rto_in_transit:   { title: 'Delivery unsuccessful', body: (o) => `We couldn't deliver order ${o.order_number}; it is being returned. Contact support if this is unexpected.`, pref: 'notify_order_cancelled' },
  rto_delivered:    { title: 'Order returned', body: (o) => `Order ${o.order_number} was returned to us. Any refund due will be processed.`, pref: 'notify_order_cancelled' },
  cancelled:        { title: 'Shipment cancelled', body: (o) => `The shipment for order ${o.order_number} was cancelled.`, pref: 'notify_order_cancelled' },
};

module.exports = { STATES, mapDelhiveryStatus, isTerminal, rankOf, labelOf, NOTIFY };
