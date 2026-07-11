const axios = require('axios');
const { getSetting } = require('./settings');

const BASE_URL = 'https://track.delhivery.com';

const getHeaders = async () => {
  const token = await getSetting('DELHIVERY_TOKEN');
  if (!token) throw new Error('Delhivery token not configured in admin credentials');
  return {
    Authorization: `Token ${token}`,
    'Content-Type': 'application/json',
  };
};

// Create a shipment on Delhivery and return the waybill number
const createShipment = async (order) => {
  const headers = await getHeaders();
  const clientName = await getSetting('DELHIVERY_CLIENT_NAME');
  const pickupLocation = await getSetting('DELHIVERY_PICKUP_LOCATION');

  if (!clientName || !pickupLocation) {
    throw new Error('Delhivery client name or pickup location not configured');
  }

  const address = order.address || {};
  const shipmentData = {
    shipments: [
      {
        name: address.name || order.customer_name,
        add: address.street || address.address_line1,
        city: address.city,
        state: address.state,
        country: 'India',
        pin: address.pincode,
        phone: order.customer_phone,
        order: order.order_number,
        payment_mode: order.payment_method === 'COD' ? 'COD' : 'Prepaid',
        return_pin: '',
        return_city: '',
        return_phone: '',
        return_add: '',
        return_name: '',
        return_state: '',
        return_country: '',
        products_desc: order.items?.map(i => i.name).join(', ') || 'Electronics',
        hsn_code: '',
        cod_amount: order.payment_method === 'COD' ? order.total : '',
        order_date: new Date(order.created_at).toISOString().split('T')[0],
        total_amount: order.total,
        seller_add: '',
        seller_name: clientName,
        seller_inv: order.order_number,
        quantity: order.items?.reduce((s, i) => s + i.quantity, 0) || 1,
        waybill: '',
        shipment_width: 15,
        shipment_height: 10,
        weight: 0.5,
        seller_gst_tin: '',
        shipping_mode: 'Surface',
        address_type: 'home',
      },
    ],
    pickup_location: { name: pickupLocation },
  };

  const response = await axios.post(
    `${BASE_URL}/api/cmu/create.json`,
    `format=json&data=${encodeURIComponent(JSON.stringify(shipmentData))}`,
    { headers: { ...headers, 'Content-Type': 'application/x-www-form-urlencoded' } }
  );

  const pkg = response.data?.packages?.[0];
  if (!pkg || pkg.error) {
    throw new Error(pkg?.error_message || pkg?.error || 'Delhivery shipment creation failed');
  }

  return pkg.waybill;
};

// Track a shipment by waybill number
const trackShipment = async (waybill) => {
  const headers = await getHeaders();
  const response = await axios.get(
    `${BASE_URL}/api/v1/packages/json/?waybill=${waybill}&verbose=1`,
    { headers }
  );

  const data = response.data?.ShipmentData?.[0]?.Shipment;
  if (!data) return null;

  return {
    waybill: data.AWB,
    status: data.Status?.Status,
    expected_delivery: data.ExpectedDeliveryDate,
    scans: (data.Scans || []).map(s => ({
      location: s.ScanDetail?.ScannedLocation,
      instructions: s.ScanDetail?.Instructions,
      status: s.ScanDetail?.Scan,
      time: s.ScanDetail?.StatusDateTime,
    })),
  };
};

module.exports = { createShipment, trackShipment };
