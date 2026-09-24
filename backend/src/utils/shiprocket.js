/**
 * Shiprocket logistics integration
 * Handles: auth (token caching), order creation, AWB assignment,
 * pickup request, and shipment tracking.
 *
 * Credentials stored in store_settings:
 *   SHIPROCKET_EMAIL           — login email
 *   SHIPROCKET_PASSWORD        — login password
 *   SHIPROCKET_PICKUP_LOCATION — pickup location name (default "Primary")
 *   SHIPROCKET_CHANNEL_ID      — optional, if using a specific sales channel
 */

const axios = require('axios');
const { getSetting } = require('./settings');

const BASE_URL = 'https://apiv2.shiprocket.in/v1/external';

// ── Token cache ────────────────────────────────────────────────────────────
// Shiprocket tokens are valid for 24 hours; cache for 23 h to be safe.
const TOKEN_TTL_MS = 23 * 60 * 60 * 1000;
let _cachedToken = null;
let _tokenTs = 0;

const authenticate = async () => {
  const email = await getSetting('SHIPROCKET_EMAIL');
  const password = await getSetting('SHIPROCKET_PASSWORD');
  if (!email || !password) {
    throw new Error('Shiprocket credentials not configured. Please set SHIPROCKET_EMAIL and SHIPROCKET_PASSWORD in Admin → Credentials.');
  }

  const res = await axios.post(`${BASE_URL}/auth/login`, { email, password });
  if (!res.data?.token) {
    throw new Error('Shiprocket authentication failed: no token returned');
  }
  _cachedToken = res.data.token;
  _tokenTs = Date.now();
  return _cachedToken;
};

const getToken = async () => {
  if (_cachedToken && Date.now() - _tokenTs < TOKEN_TTL_MS) return _cachedToken;
  return authenticate();
};

const authHeaders = async () => ({
  Authorization: `Bearer ${await getToken()}`,
  'Content-Type': 'application/json',
});

// ── Create shipment ────────────────────────────────────────────────────────
/**
 * Full shipment creation flow:
 *   1. Create order on Shiprocket
 *   2. Assign best AWB (auto-select courier)
 *   3. Request pickup
 *
 * Returns the AWB code string (used as tracking_id in our DB).
 */
const createShipmentOrder = async (order) => {
  const headers = await authHeaders();
  const pickupLocation = (await getSetting('SHIPROCKET_PICKUP_LOCATION')) || 'Primary';
  const channelId = await getSetting('SHIPROCKET_CHANNEL_ID');

  const address = order.address || {};
  const fullName = (address.name || order.customer_name || '').trim();
  const [firstName, ...rest] = fullName.split(' ');
  const lastName = rest.join(' ') || '.';

  // Build item list
  const orderItems = (order.items || []).map((item, idx) => ({
    name: item.name || `Product ${idx + 1}`,
    sku: item.product_id || `SKU${idx + 1}`,
    units: item.quantity || 1,
    selling_price: parseFloat(item.price) || 0,
    discount: 0,
    tax: '',
    hsn: '',
  }));

  if (!orderItems.length) {
    orderItems.push({ name: 'Electronics', sku: 'PROD001', units: 1, selling_price: parseFloat(order.total) || 0 });
  }

  const payload = {
    order_id: order.order_number,
    order_date: new Date(order.created_at).toISOString().replace('T', ' ').slice(0, 19),
    pickup_location: pickupLocation,
    ...(channelId ? { channel_id: parseInt(channelId) } : {}),

    // Billing (same as shipping for simplicity — most e-commerce does this)
    billing_customer_name: firstName,
    billing_last_name: lastName,
    billing_address: address.street || address.line1 || address.address_line1 || '',
    billing_address_2: address.line2 || address.address_line2 || '',
    billing_city: address.city || '',
    billing_pincode: address.pincode || '',
    billing_state: address.state || '',
    billing_country: 'India',
    billing_email: order.customer_email || 'noreply@chillfi.in',
    billing_phone: address.phone || order.customer_phone || '',

    shipping_is_billing: true,

    order_items: orderItems,

    payment_method: order.payment_method === 'COD' ? 'COD' : 'Prepaid',
    sub_total: parseFloat(order.total) || 0,

    // Default package dimensions (kg/cm)
    length: 15,
    breadth: 12,
    height: 10,
    weight: 0.5,
  };

  // 1. Create the order
  const createRes = await axios.post(`${BASE_URL}/orders/create/adhoc`, payload, { headers });
  const shipmentId = createRes.data?.shipment_id;
  const orderId = createRes.data?.order_id;

  if (!shipmentId) {
    throw new Error(
      `Shiprocket order creation failed: ${createRes.data?.message || JSON.stringify(createRes.data)}`
    );
  }

  // 2. Assign AWB (auto-picks best courier based on rate, availability, pincode serviceability)
  const awbRes = await axios.post(
    `${BASE_URL}/courier/assign/awb`,
    { shipment_id: String(shipmentId) },
    { headers }
  );

  const awb = awbRes.data?.response?.data?.awb_code;
  if (!awb) {
    throw new Error(
      `Shiprocket AWB assignment failed: ${awbRes.data?.response?.data?.awb_assign_error || awbRes.data?.message || 'Unknown error'}`
    );
  }

  // 3. Request pickup
  try {
    await axios.post(
      `${BASE_URL}/courier/generate/pickup`,
      { shipment_id: [shipmentId] },
      { headers }
    );
  } catch {
    // Pickup request failure is non-fatal — AWB is already assigned.
    // Pickup can be scheduled manually from the Shiprocket dashboard.
  }

  return awb;
};

// ── Track shipment ─────────────────────────────────────────────────────────
/**
 * Fetches live tracking data for a given AWB code.
 * Returns a normalized object matching the Delhivery format so the
 * Flutter app and admin panel don't need separate handling per courier.
 */
const trackShipment = async (awb) => {
  const headers = await authHeaders();

  const res = await axios.get(`${BASE_URL}/courier/track/awb/${awb}`, { headers });
  const trackData = res.data?.tracking_data;

  if (!trackData) return null;

  const shipmentTrack = trackData.shipment_track?.[0] || {};
  const activities = trackData.shipment_track_activities || [];

  // Normalize to the same shape as delhivery.trackShipment()
  return {
    waybill: awb,
    status: shipmentTrack.current_status || trackData.shipment_status || 'Unknown',
    expected_delivery: shipmentTrack.expected_delivery_date || null,
    courier_name: shipmentTrack.courier_company_id || 'Shiprocket',
    scans: activities.map((a) => ({
      location: a.location || '',
      instructions: a.activity || '',
      status: a.activity || '',
      time: a.date || null,
    })),
  };
};

// Invalidate cached token (call on credential update)
const invalidateToken = () => {
  _cachedToken = null;
  _tokenTs = 0;
};

module.exports = { createShipmentOrder, trackShipment, invalidateToken };
