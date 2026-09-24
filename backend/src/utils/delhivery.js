/**
 * Delhivery B2C (Express) API client.
 * Docs: https://delhivery-express-api-doc.readme.io/reference
 *
 * Environment is selected by the DELHIVERY_ENV setting ('staging' | 'production'),
 * editable from Admin → Settings → Shipping. Each environment has its own token and
 * pickup-location name, so switching to production is a config change only.
 *
 *   staging    → DELHIVERY_STAGING_TOKEN, DELHIVERY_STAGING_PICKUP_LOCATION
 *   production → DELHIVERY_TOKEN,         DELHIVERY_PICKUP_LOCATION
 *   shared     → DELHIVERY_CLIENT_NAME, DELHIVERY_SELLER_GST, DELHIVERY_DEFAULT_WEIGHT_GRAMS
 */
const axios = require('axios');
const { getSetting } = require('./settings');

const BASE_URLS = {
  staging: 'https://staging-express.delhivery.com',
  production: 'https://track.delhivery.com',
};
const TIMEOUT_MS = 20000;

class DelhiveryError extends Error {
  constructor(message, { code, retryable = false, status } = {}) {
    super(message);
    this.name = 'DelhiveryError';
    this.code = code;
    this.retryable = retryable;
    this.status = status;
  }
}

const getEnv = async () => {
  const env = ((await getSetting('DELHIVERY_ENV')) || 'staging').toLowerCase();
  return env === 'production' ? 'production' : 'staging';
};

const getConfig = async () => {
  const env = await getEnv();
  const isProd = env === 'production';
  // Base-URL override exists only for local simulator testing and is never honoured in production.
  const override = !isProd && process.env.DELHIVERY_STAGING_BASE_URL;
  return {
    env,
    baseUrl: override || BASE_URLS[env],
    token: await getSetting(isProd ? 'DELHIVERY_TOKEN' : 'DELHIVERY_STAGING_TOKEN'),
    pickupLocation: await getSetting(isProd ? 'DELHIVERY_PICKUP_LOCATION' : 'DELHIVERY_STAGING_PICKUP_LOCATION'),
    clientName: await getSetting('DELHIVERY_CLIENT_NAME'),
    sellerGst: (await getSetting('DELHIVERY_SELLER_GST')) || '',
    weightGrams: parseInt(await getSetting('DELHIVERY_DEFAULT_WEIGHT_GRAMS'), 10) || 500,
  };
};

const configProblems = (cfg) => {
  const missing = [];
  if (!cfg.token) missing.push(cfg.env === 'production' ? 'DELHIVERY_TOKEN' : 'DELHIVERY_STAGING_TOKEN');
  if (!cfg.pickupLocation) missing.push(cfg.env === 'production' ? 'DELHIVERY_PICKUP_LOCATION' : 'DELHIVERY_STAGING_PICKUP_LOCATION');
  return missing;
};

const isConfigured = async () => configProblems(await getConfig()).length === 0;

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

// Wraps axios so failures become DelhiveryError without leaking the token.
// Delhivery throttles bursts with 429 "Throttled, wait N seconds" — honour it and retry (max 3).
const request = async (cfg, opts, attempt = 1) => {
  try {
    return await requestOnce(cfg, opts);
  } catch (err) {
    if (err.status === 429 && attempt <= 3) {
      const secs = Math.min(parseInt((err.message.match(/wait (\d+) second/i) || [])[1], 10) || 5, 30);
      console.warn(`[delhivery] throttled on ${opts.path}; retrying in ${secs}s (attempt ${attempt}/3)`);
      await sleep(secs * 1000);
      return request(cfg, opts, attempt + 1);
    }
    throw err;
  }
};

const requestOnce = async (cfg, { method = 'get', path, params, data, headers = {} }) => {
  if (!cfg.token) throw new DelhiveryError(`Delhivery ${cfg.env} token not configured`, { code: 'NOT_CONFIGURED' });
  try {
    const res = await axios({
      method,
      url: `${cfg.baseUrl}${path}`,
      params,
      data,
      timeout: TIMEOUT_MS,
      headers: { Authorization: `Token ${cfg.token}`, Accept: 'application/json', ...headers },
    });
    return res.data;
  } catch (err) {
    const status = err.response?.status;
    const body = err.response?.data;
    const raw = typeof body === 'string' ? body : body?.rmk || body?.error || body?.detail || body;
    const detail = raw == null ? err.message : (typeof raw === 'string' ? raw : JSON.stringify(raw)).slice(0, 300);
    const retryable = !status || status >= 500 || status === 429 || err.code === 'ECONNABORTED';
    throw new DelhiveryError(`Delhivery ${method.toUpperCase()} ${path} failed${status ? ` (${status})` : ''}: ${detail}`, {
      code: status === 401 || status === 403 ? 'AUTH' : 'HTTP', retryable, status,
    });
  }
};

// ── Pincode serviceability ──────────────────────────────────────────────────
const checkPincode = async (pincode) => {
  const cfg = await getConfig();
  const data = await request(cfg, { path: '/c/api/pin-codes/json/', params: { filter_codes: pincode } });
  const pc = data?.delivery_codes?.[0]?.postal_code;
  if (!pc) return { serviceable: false, pincode };
  return {
    serviceable: true,
    pincode,
    cod: pc.cod === 'Y' || pc.cash === 'Y',
    prepaid: pc.pre_paid === 'Y',
    pickup: pc.pickup === 'Y',
    city: pc.city || pc.district || null,
    state: pc.state_code || null,
  };
};

// Cached serviceability for checkout. Returns { serviceable: true|false|null, cod } —
// null means "unknown" (Delhivery not configured / API error): callers must NOT block on null.
const _pinCache = new Map();
const PIN_TTL_MS = 6 * 60 * 60 * 1000;
const pincodeServiceability = async (pincode) => {
  const pin = String(pincode || '').trim();
  if (!/^[1-9]\d{5}$/.test(pin)) return { serviceable: false, cod: false, pincode: pin, reason: 'invalid' };
  const hit = _pinCache.get(pin);
  if (hit && Date.now() - hit.at < PIN_TTL_MS) return hit.value;
  let value;
  try {
    if (!(await isConfigured())) return { serviceable: null, cod: null, pincode: pin };
    const r = await checkPincode(pin);
    value = { serviceable: r.serviceable, cod: r.serviceable ? !!r.cod : false, pincode: pin, city: r.city || null };
  } catch (err) {
    console.warn(`[delhivery] pincode check failed pin=${pin}: ${err.message}`);
    return { serviceable: null, cod: null, pincode: pin };
  }
  _pinCache.set(pin, { at: Date.now(), value });
  return value;
};

// ── Order creation / manifestation ──────────────────────────────────────────
const formatOrderDate = (d) => {
  const dt = new Date(d || Date.now());
  const pad = (n) => String(n).padStart(2, '0');
  return `${dt.getFullYear()}-${pad(dt.getMonth() + 1)}-${pad(dt.getDate())} ${pad(dt.getHours())}:${pad(dt.getMinutes())}:${pad(dt.getSeconds())}`;
};

const buildShipmentPayload = (order, cfg) => {
  const a = order.address || {};
  const items = order.items || [];
  const isCod = order.payment_method === 'COD';
  const total = Math.round(parseFloat(order.total) || 0);
  const addressLine = [a.line1, a.line2].filter(Boolean).join(', ');
  const phone = String(a.phone || order.customer_phone || '').replace(/\D/g, '').slice(-10);

  return {
    shipments: [{
      name: a.name || order.customer_name || 'Customer',
      add: addressLine,
      pin: String(a.pincode || ''),
      city: a.city || '',
      state: a.state || '',
      country: 'India',
      phone,
      order: order.order_number,
      payment_mode: isCod ? 'COD' : 'Prepaid',
      cod_amount: isCod ? total : 0,
      total_amount: total,
      order_date: formatOrderDate(order.created_at),
      products_desc: items.map((i) => `${i.name} x${i.quantity}`).join(', ').slice(0, 250) || 'Electronics',
      quantity: String(items.reduce((s, i) => s + (parseInt(i.quantity, 10) || 0), 0) || 1),
      seller_name: cfg.clientName || '',
      seller_inv: order.order_number,
      seller_gst_tin: cfg.sellerGst,
      hsn_code: '',
      weight: cfg.weightGrams,           // grams
      shipment_length: 20,               // cm
      shipment_width: 15,
      shipment_height: 10,
      shipping_mode: 'Surface',
      address_type: 'home',
    }],
    pickup_location: { name: cfg.pickupLocation },
  };
};

const validateForShipment = (order) => {
  const a = order.address || {};
  const problems = [];
  if (!a.line1) problems.push('address line');
  if (!/^\d{6}$/.test(String(a.pincode || ''))) problems.push('6-digit pincode');
  if (String(a.phone || order.customer_phone || '').replace(/\D/g, '').length < 10) problems.push('10-digit phone');
  if (!a.city) problems.push('city');
  return problems;
};

/**
 * Creates (manifests) a forward shipment. Returns { waybill, env, recovered }.
 * If Delhivery reports the order id already exists (e.g. a previous call timed out
 * after Delhivery accepted it) the existing waybill is looked up and returned instead
 * of creating a second shipment.
 */
const createShipment = async (order) => {
  const cfg = await getConfig();
  const missing = configProblems(cfg);
  if (missing.length) throw new DelhiveryError(`Delhivery not configured: set ${missing.join(', ')}`, { code: 'NOT_CONFIGURED' });

  const problems = validateForShipment(order);
  if (problems.length) throw new DelhiveryError(`Order address invalid for shipping: missing/invalid ${problems.join(', ')}`, { code: 'INVALID_ADDRESS' });

  const payload = buildShipmentPayload(order, cfg);
  const data = await request(cfg, {
    method: 'post',
    path: '/api/cmu/create.json',
    data: `format=json&data=${encodeURIComponent(JSON.stringify(payload))}`,
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  });

  const pkg = data?.packages?.[0];
  if (pkg?.waybill && (pkg.status || '').toLowerCase() === 'success') {
    return { waybill: String(pkg.waybill), env: cfg.env, recovered: false };
  }

  const remarks = [...new Set([].concat(pkg?.remarks || [], data?.rmk || []).filter(Boolean))].join('; ');
  if (/duplicate|already exist/i.test(remarks)) {
    const existing = await findWaybillByOrderRef(order.order_number, cfg);
    if (existing) return { waybill: existing, env: cfg.env, recovered: true };
  }
  throw new DelhiveryError(`Delhivery rejected shipment: ${remarks || 'unknown error'}`, { code: 'REJECTED' });
};

const findWaybillByOrderRef = async (orderNumber, cfgIn) => {
  const cfg = cfgIn || (await getConfig());
  const data = await request(cfg, { path: '/api/v1/packages/json/', params: { ref_ids: orderNumber } });
  return data?.ShipmentData?.[0]?.Shipment?.AWB || null;
};

// ── Tracking (pull) ─────────────────────────────────────────────────────────
// Delhivery timestamps are IST without an offset; tag them so they parse correctly.
const parseDlvTime = (s) => {
  if (!s) return null;
  const str = String(s);
  const withTz = /[zZ]|[+-]\d{2}:?\d{2}$/.test(str) ? str : `${str}+05:30`;
  const d = new Date(withTz);
  return isNaN(d) ? null : d;
};

const normalizeShipment = (s) => {
  if (!s) return null;
  const st = s.Status || {};
  return {
    waybill: String(s.AWB || ''),
    reference: s.ReferenceNo || null,
    status: st.Status || null,
    status_type: st.StatusType || null,
    status_time: parseDlvTime(st.StatusDateTime),
    location: st.StatusLocation || null,
    instructions: st.Instructions || null,
    expected_delivery: parseDlvTime(s.ExpectedDeliveryDate || s.PromisedDeliveryDate),
    pickup_date: parseDlvTime(s.PickUpDate),
    scans: (s.Scans || []).map(({ ScanDetail: d = {} }) => ({
      status: d.Scan || null,
      status_type: d.ScanType || null,
      location: d.ScannedLocation || null,
      instructions: d.Instructions || null,
      time: parseDlvTime(d.ScanDateTime || d.StatusDateTime),
    })),
  };
};

// Accepts up to 50 waybills per call (documented pull API limit: 750 req / 5 min / IP).
// Observed on real staging: if several waybills in a batch are unknown to Delhivery, the WHOLE
// batch comes back as {Success:false, Error:"Data does not exists..."} — valid ones included.
// So on a whole-batch miss we split and retry, isolating unknown AWBs instead of dropping good ones.
const trackWaybills = async (waybills, cfgIn) => {
  const cfg = cfgIn || (await getConfig());
  const data = await request(cfg, { path: '/api/v1/packages/json/', params: { waybill: waybills.join(','), verbose: 1 } });
  if (Array.isArray(data?.ShipmentData)) {
    return data.ShipmentData.map((x) => normalizeShipment(x.Shipment)).filter(Boolean);
  }
  if (waybills.length > 1) {
    const mid = Math.ceil(waybills.length / 2);
    const left = await trackWaybills(waybills.slice(0, mid), cfg);
    await sleep(400); // stay under Delhivery's burst throttle
    return [...left, ...(await trackWaybills(waybills.slice(mid), cfg))];
  }
  console.warn(`[delhivery] waybill ${waybills[0]} unknown to Delhivery ${cfg.env}`);
  return [];
};

const trackShipment = async (waybill) => (await trackWaybills([waybill]))[0] || null;

// ── Cancellation ────────────────────────────────────────────────────────────
// Allowed by Delhivery while Manifested / In Transit / Pending / Open / Scheduled.
const cancelShipment = async (waybill) => {
  const cfg = await getConfig();
  const data = await request(cfg, {
    method: 'post', path: '/api/p/edit',
    data: { waybill: String(waybill), cancellation: 'true' },
    headers: { 'Content-Type': 'application/json' },
  });
  if (data?.status === true || /cancel/i.test(data?.remark || '')) return { cancelled: true, remark: data?.remark };
  throw new DelhiveryError(`Delhivery cancellation failed: ${data?.remark || data?.error || 'unknown'}`, { code: 'REJECTED' });
};

// ── Pickup request ──────────────────────────────────────────────────────────
// Delhivery only collects manifested parcels once a pickup request exists for the warehouse.
// One open request per warehouse at a time; a duplicate returns pr_exist=true, which we treat as OK.
const requestPickup = async ({ date, time, count }) => {
  const cfg = await getConfig();
  const missing = configProblems(cfg);
  if (missing.length) throw new DelhiveryError(`Delhivery not configured: set ${missing.join(', ')}`, { code: 'NOT_CONFIGURED' });
  let data;
  try {
    data = await request(cfg, {
      method: 'post', path: '/fm/request/new/',
      data: { pickup_time: time, pickup_date: date, pickup_location: cfg.pickupLocation, expected_package_count: Math.max(1, count || 1) },
      headers: { 'Content-Type': 'application/json' },
    });
  } catch (err) {
    // Delhivery answers an already-open request with a 4xx body carrying pr_exist
    if (err.status && err.status < 500 && /pr_exist|already (exists|in progress)/i.test(err.message)) return { ok: true, existing: true, message: err.message };
    throw err;
  }
  if (data?.pickup_id && data?.success !== false) return { ok: true, existing: false, pickup_id: data.pickup_id, date: data.pickup_date || date, time: data.pickup_time || time };
  if (data?.pr_exist) return { ok: true, existing: true, pickup_id: data.pickup_id || null, message: data?.data?.message || data?.error?.message };
  // Live staging also answers "Pickup request creation is already in progress for this client warehouse"
  const text = JSON.stringify(data || {});
  if (/already (exists|in progress)|pickup request .* already/i.test(text)) return { ok: true, existing: true, pickup_id: data?.pickup_id || null, message: text.slice(0, 200) };
  throw new DelhiveryError(`Pickup request failed: ${data?.error?.message || data?.pickup_location || data?.error || JSON.stringify(data).slice(0, 200)}`, { code: 'REJECTED' });
};

// ── Shipping label (packing slip) ───────────────────────────────────────────
const getPackingSlip = async (waybill) => {
  const cfg = await getConfig();
  const data = await request(cfg, { path: '/api/p/packing_slip', params: { wbns: waybill, pdf: 'true' } });
  const pkg = data?.packages?.[0];
  if (!pkg) throw new DelhiveryError('Label not available yet for this waybill', { code: 'NOT_FOUND' });
  return { waybill, pdf_url: pkg.pdf_download_link || null, package: pkg };
};

// Lightweight authenticated call used by Admin "Test connection".
const testConnection = async (pincode = '110001') => {
  const cfg = await getConfig();
  const missing = configProblems(cfg);
  if (missing.length) return { ok: false, env: cfg.env, message: `Missing: ${missing.join(', ')}` };
  try {
    const r = await checkPincode(pincode);
    return { ok: true, env: cfg.env, message: `Connected (${cfg.env}). Pincode ${pincode} ${r.serviceable ? 'serviceable' : 'not serviceable'}.` };
  } catch (err) {
    return { ok: false, env: cfg.env, message: err.message };
  }
};

module.exports = {
  pincodeServiceability,
  DelhiveryError, getEnv, getConfig, isConfigured, configProblems,
  checkPincode, createShipment, findWaybillByOrderRef,
  trackShipment, trackWaybills, normalizeShipment, parseDlvTime,
  cancelShipment, testConnection, requestPickup, getPackingSlip,
};
