// GST tax invoices (India, B2C). Prices are GST-inclusive, so each line's taxable value is worked back out:
//   taxable = amount × 100 / (100 + rate);  intra-state → CGST + SGST (half each), inter-state → IGST.
// Numbers are sequential per financial year: CF/<YY><YY>/<000001> (≤16 chars, as GST rules require).
const path = require('path');
const PDFDocument = require('pdfkit');
const pool = require('../db/pool');

const FONT_DIR = path.join(__dirname, '../../assets/fonts');
const GSTIN_RE = /^\d{2}[A-Z]{5}\d{4}[A-Z][1-9A-Z]Z[0-9A-Z]$/;

// GST state codes, keyed by lower-case name and common abbreviations.
const STATES = [
  ['01', 'Jammu and Kashmir', ['jk', 'j&k', 'jammu & kashmir']], ['02', 'Himachal Pradesh', ['hp']], ['03', 'Punjab', ['pb']],
  ['04', 'Chandigarh', ['ch']], ['05', 'Uttarakhand', ['uk', 'uttaranchal']], ['06', 'Haryana', ['hr']], ['07', 'Delhi', ['dl', 'new delhi', 'nct of delhi']],
  ['08', 'Rajasthan', ['rj']], ['09', 'Uttar Pradesh', ['up']], ['10', 'Bihar', ['br']], ['11', 'Sikkim', ['sk']],
  ['12', 'Arunachal Pradesh', ['ar']], ['13', 'Nagaland', ['nl']], ['14', 'Manipur', ['mn']], ['15', 'Mizoram', ['mz']],
  ['16', 'Tripura', ['tr']], ['17', 'Meghalaya', ['ml']], ['18', 'Assam', ['as']], ['19', 'West Bengal', ['wb']],
  ['20', 'Jharkhand', ['jh']], ['21', 'Odisha', ['or', 'od', 'orissa']], ['22', 'Chhattisgarh', ['cg', 'ct', 'chattisgarh']],
  ['23', 'Madhya Pradesh', ['mp']], ['24', 'Gujarat', ['gj']], ['26', 'Dadra and Nagar Haveli and Daman and Diu', ['dnh', 'dd', 'daman and diu']],
  ['27', 'Maharashtra', ['mh']], ['29', 'Karnataka', ['ka']], ['30', 'Goa', ['ga']], ['31', 'Lakshadweep', ['ld']],
  ['32', 'Kerala', ['kl']], ['33', 'Tamil Nadu', ['tn']], ['34', 'Puducherry', ['py', 'pondicherry']],
  ['35', 'Andaman and Nicobar Islands', ['an']], ['36', 'Telangana', ['ts', 'tg']], ['37', 'Andhra Pradesh', ['ap']], ['38', 'Ladakh', ['la']],
];
const byName = new Map();
for (const [code, name, alts] of STATES) { byName.set(name.toLowerCase(), { code, name }); alts.forEach((a) => byName.set(a, { code, name })); }
const stateByCode = (code) => { const s = STATES.find((x) => x[0] === code); return s ? { code, name: s[1] } : null; };
const resolveState = (v) => byName.get(String(v || '').trim().toLowerCase().replace(/\s+/g, ' ')) || null;

const r2 = (n) => Math.round(n * 100) / 100;
const inr = (n) => `₹${Number(n).toLocaleString('en-IN', { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;

// Indian-system amount in words, e.g. 1,23,456.50 → "One Lakh Twenty Three Thousand Four Hundred Fifty Six Rupees and Fifty Paise Only".
const ONES = ['', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine', 'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen', 'Seventeen', 'Eighteen', 'Nineteen'];
const TENS = ['', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'];
const two = (n) => (n < 20 ? ONES[n] : `${TENS[Math.floor(n / 10)]}${n % 10 ? ` ${ONES[n % 10]}` : ''}`);
const three = (n) => (n >= 100 ? `${ONES[Math.floor(n / 100)]} Hundred${n % 100 ? ` ${two(n % 100)}` : ''}` : two(n));
const words = (n) => {
  if (n === 0) return 'Zero';
  const parts = [];
  const crore = Math.floor(n / 1e7); n %= 1e7;
  const lakh = Math.floor(n / 1e5); n %= 1e5;
  const thousand = Math.floor(n / 1e3); n %= 1e3;
  if (crore) parts.push(`${words(crore)} Crore`);
  if (lakh) parts.push(`${two(lakh)} Lakh`);
  if (thousand) parts.push(`${two(thousand)} Thousand`);
  if (n) parts.push(three(n));
  return parts.join(' ');
};
const amountInWords = (amt) => {
  const rupees = Math.floor(amt + 1e-9); const paise = Math.round((amt - rupees) * 100);
  return `${words(rupees)} Rupees${paise ? ` and ${two(paise)} Paise` : ''} Only`;
};

const financialYear = (d = new Date()) => {
  const ist = new Date(d.getTime() + 5.5 * 3600e3);
  const y = ist.getUTCFullYear(); const start = ist.getUTCMonth() >= 3 ? y : y - 1; // FY starts 1 April
  return `${String(start).slice(2)}${String(start + 1).slice(2)}`;
};

const getSellerSettings = async () => {
  const rows = (await pool.query(`SELECT key, value FROM store_settings WHERE key IN
    ('store_name','store_address','gst_number','gst_rate','invoices_enabled','store_phone','support_email','store_email')`)).rows;
  const s = Object.fromEntries(rows.map((r) => [r.key, r.value]));
  const gstin = String(s.gst_number || '').trim().toUpperCase();
  return {
    name: s.store_name || 'ChillFi', address: s.store_address || '', gstin, gstinValid: GSTIN_RE.test(gstin),
    state: GSTIN_RE.test(gstin) ? stateByCode(gstin.slice(0, 2)) : null,
    rate: parseFloat(s.gst_rate ?? 18), enabled: s.invoices_enabled === 'true',
    phone: s.store_phone || '', email: s.support_email || s.store_email || '',
  };
};

/** Why an order can't have an invoice yet (null = it can). */
const invoiceBlocker = (order, seller) => {
  if (!seller.enabled) return 'Invoices are not enabled yet.';
  if (!seller.gstinValid) return 'The store GSTIN is not set up correctly.';
  if (order.status === 'Cancelled') return 'Cancelled orders have no invoice.';
  if (!['Shipped', 'Delivered'].includes(order.status)) return 'Your invoice will be available once the order has shipped.';
  return null;
};

/** Assigns the next number of the current financial year (idempotent; row-locked). */
const ensureInvoiceNumber = async (orderId) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const o = (await client.query('SELECT invoice_number, invoice_date FROM orders WHERE id = $1 FOR UPDATE', [orderId])).rows[0];
    if (o.invoice_number) { await client.query('COMMIT'); return o; }
    const fy = financialYear();
    await client.query('INSERT INTO invoice_counters (fy, last_no) VALUES ($1, 0) ON CONFLICT (fy) DO NOTHING', [fy]);
    const n = (await client.query('UPDATE invoice_counters SET last_no = last_no + 1 WHERE fy = $1 RETURNING last_no', [fy])).rows[0].last_no;
    const number = `CF/${fy}/${String(n).padStart(6, '0')}`;
    const upd = (await client.query('UPDATE orders SET invoice_number = $1, invoice_date = NOW() WHERE id = $2 RETURNING invoice_number, invoice_date', [number, orderId])).rows[0];
    await client.query('COMMIT');
    return upd;
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  } finally { client.release(); }
};

/** Pure calculation of all invoice figures (exported for tests). */
// inclusive=false reproduces orders placed before 25 Sep 2026, when GST was added on top of item prices
// (and delivery carried no GST) — the invoice must match what the customer was actually charged.
const computeInvoice = ({ items, discount, deliveryFee, rate, intraState, inclusive = true }) => {
  const gross = items.reduce((s, i) => s + i.price * i.quantity, 0);
  const lines = items.map((i) => {
    const value = i.price * i.quantity;
    const share = gross > 0 ? (discount * value) / gross : 0; // coupon spread proportionally
    const net = r2(value - share);
    const taxable = inclusive ? r2((net * 100) / (100 + rate)) : net;
    const tax = inclusive ? r2(net - taxable) : r2((net * rate) / 100);
    return { name: i.name, hsn: i.hsn || '', qty: i.quantity, unit: i.price, discount: r2(share), amount: r2(taxable + tax), taxable, tax };
  });
  if (deliveryFee > 0 && !inclusive) {
    lines.push({ name: 'Shipping charges', hsn: '996812', qty: 1, unit: deliveryFee, discount: 0, amount: r2(deliveryFee), taxable: r2(deliveryFee), tax: 0 });
  } else if (deliveryFee > 0) {
    const taxable = r2((deliveryFee * 100) / (100 + rate));
    lines.push({ name: 'Shipping charges', hsn: '996812', qty: 1, unit: deliveryFee, discount: 0, amount: r2(deliveryFee), taxable, tax: r2(deliveryFee - taxable) });
  }
  const totals = lines.reduce((t, l) => ({ taxable: t.taxable + l.taxable, tax: t.tax + l.tax, amount: t.amount + l.amount }), { taxable: 0, tax: 0, amount: 0 });
  totals.taxable = r2(totals.taxable); totals.tax = r2(totals.tax); totals.amount = r2(totals.amount);
  const split = intraState ? { cgst: r2(totals.tax / 2), sgst: r2(totals.tax - r2(totals.tax / 2)), igst: 0 } : { cgst: 0, sgst: 0, igst: totals.tax };
  return { lines, totals, split };
};

const loadOrder = async (orderId) => {
  const o = (await pool.query(`
    SELECT o.*, u.name AS customer_name, u.email AS customer_email,
      COALESCE(o.shipping_address->>'name', a.name) AS s_name, COALESCE(o.shipping_address->>'phone', a.phone) AS s_phone,
      COALESCE(o.shipping_address->>'line1', a.line1) AS s_line1, COALESCE(o.shipping_address->>'line2', a.line2) AS s_line2,
      COALESCE(o.shipping_address->>'city', a.city) AS s_city, COALESCE(o.shipping_address->>'state', a.state) AS s_state,
      COALESCE(o.shipping_address->>'pincode', a.pincode) AS s_pincode
    FROM orders o LEFT JOIN users u ON u.id = o.user_id LEFT JOIN addresses a ON a.id = o.address_id WHERE o.id = $1`, [orderId])).rows[0];
  if (!o) return null;
  o.items = (await pool.query(`SELECT oi.product_name AS name, oi.quantity, oi.price, p.hsn_code AS hsn
    FROM order_items oi LEFT JOIN products p ON p.id = oi.product_id WHERE oi.order_id = $1 ORDER BY oi.product_name`, [orderId])).rows
    .map((i) => ({ ...i, price: parseFloat(i.price), quantity: Number(i.quantity) }));
  return o;
};

const renderPdf = (inv) => new Promise((resolve, reject) => {
  const doc = new PDFDocument({ size: 'A4', margin: 40, info: { Title: `Tax Invoice ${inv.number}`, Author: inv.seller.name } });
  const chunks = [];
  doc.on('data', (c) => chunks.push(c)); doc.on('end', () => resolve(Buffer.concat(chunks))); doc.on('error', reject);
  doc.registerFont('R', path.join(FONT_DIR, 'Poppins-Regular.ttf'));
  doc.registerFont('S', path.join(FONT_DIR, 'Poppins-SemiBold.ttf'));
  doc.registerFont('B', path.join(FONT_DIR, 'Poppins-Bold.ttf'));
  const W = doc.page.width - 80; const L = 40;

  doc.font('B').fontSize(18).fillColor('#111827').text('TAX INVOICE', L, 40);
  doc.font('R').fontSize(8).fillColor('#6B7280').text('Original for recipient', L, 62);
  doc.font('B').fontSize(12).fillColor('#FF6B2C').text(inv.seller.name, L, 40, { width: W, align: 'right' });
  doc.font('R').fontSize(8).fillColor('#374151')
    .text(inv.seller.address, L + W / 2, 58, { width: W / 2, align: 'right' })
    .text(`GSTIN: ${inv.seller.gstin}   State: ${inv.seller.state.name} (${inv.seller.state.code})`, { width: W / 2, align: 'right' });
  if (inv.seller.email || inv.seller.phone) doc.text([inv.seller.phone, inv.seller.email].filter(Boolean).join('  ·  '), { width: W / 2, align: 'right' });

  let y = Math.max(doc.y, 100) + 12;
  doc.moveTo(L, y).lineTo(L + W, y).strokeColor('#E5E7EB').stroke(); y += 10;
  const kv = (x, yy, k, v) => { doc.font('S').fontSize(8).fillColor('#6B7280').text(k, x, yy); doc.font('R').fontSize(9).fillColor('#111827').text(v, x, yy + 11); };
  kv(L, y, 'Invoice No.', inv.number); kv(L + 130, y, 'Invoice Date', inv.date);
  kv(L + 250, y, 'Order No.', inv.orderNumber); kv(L + 380, y, 'Order Date', inv.orderDate);
  y += 34;
  kv(L, y, 'Place of Supply', `${inv.placeOfSupply.name} (${inv.placeOfSupply.code})`); kv(L + 250, y, 'Payment', inv.payment);
  y += 36;
  doc.font('S').fontSize(8).fillColor('#6B7280').text('Bill To / Ship To', L, y);
  doc.font('R').fontSize(9).fillColor('#111827').text(inv.buyer.join('\n'), L, y + 11, { width: W / 2 });
  y = doc.y + 14;

  // Items table
  const cols = inv.intraState
    ? [['#', 18], ['Item', 150], ['HSN', 42], ['Qty', 26], ['Price', 62], ['Taxable', 62], [`CGST ${inv.rate / 2}%`, 50], [`SGST ${inv.rate / 2}%`, 50], ['Total', 55]]
    : [['#', 18], ['Item', 175], ['HSN', 42], ['Qty', 26], ['Price', 62], ['Taxable', 62], [`IGST ${inv.rate}%`, 70], ['Total', 60]];
  const drawRow = (vals, yy, font = 'R', fill = null) => {
    let x = L; const h = Math.max(...vals.map((v, i) => doc.font(font).fontSize(8).heightOfString(String(v), { width: cols[i][1] - 4 }))) + 8;
    if (fill) doc.rect(L, yy, W, h).fill(fill);
    vals.forEach((v, i) => { doc.font(font).fontSize(8).fillColor('#111827').text(String(v), x + 2, yy + 4, { width: cols[i][1] - 4, align: i >= 3 ? 'right' : 'left' }); x += cols[i][1]; });
    return yy + h;
  };
  y = drawRow(cols.map((c) => c[0]), y, 'S', '#F3F4F6');
  inv.lines.forEach((l, idx) => {
    const half = r2(l.tax / 2);
    const vals = inv.intraState
      ? [idx + 1, l.name + (l.discount ? `\n(coupon −${inr(l.discount)})` : ''), l.hsn || '—', l.qty, inr(l.unit), inr(l.taxable), inr(half), inr(r2(l.tax - half)), inr(l.amount)]
      : [idx + 1, l.name + (l.discount ? `\n(coupon −${inr(l.discount)})` : ''), l.hsn || '—', l.qty, inr(l.unit), inr(l.taxable), inr(l.tax), inr(l.amount)];
    y = drawRow(vals, y);
    doc.moveTo(L, y).lineTo(L + W, y).strokeColor('#F3F4F6').stroke();
  });
  y += 10;
  const tot = (k, v, bold) => { doc.font(bold ? 'B' : 'R').fontSize(bold ? 10 : 9).fillColor('#111827').text(k, L + W - 260, y, { width: 150 }).text(v, L + W - 110, y, { width: 110, align: 'right' }); y += bold ? 18 : 14; };
  tot('Taxable value', inr(inv.totals.taxable));
  if (inv.intraState) { tot(`CGST @ ${inv.rate / 2}%`, inr(inv.split.cgst)); tot(`SGST @ ${inv.rate / 2}%`, inr(inv.split.sgst)); } else tot(`IGST @ ${inv.rate}%`, inr(inv.split.igst));
  tot('Invoice total', inr(inv.totals.amount), true);
  doc.font('R').fontSize(8).fillColor('#374151').text(`Amount in words: ${amountInWords(inv.totals.amount)}`, L, y + 2, { width: W });
  doc.text('Tax payable on reverse charge: No', L, doc.y + 2);
  doc.font('R').fontSize(7.5).fillColor('#6B7280').text('This is a computer-generated invoice and does not require a physical signature.', L, doc.y + 18, { width: W });
  doc.font('S').fontSize(8).fillColor('#111827').text(`For ${inv.seller.name}\nAuthorised Signatory`, L, doc.y - 8, { width: W, align: 'right' });
  doc.end();
});

/** Builds (and numbers, first time) the invoice PDF for an order. Throws {status, message} when not available. */
const buildInvoicePdf = async (orderId) => {
  const seller = await getSellerSettings();
  const order = await loadOrder(orderId);
  if (!order) throw Object.assign(new Error('Order not found'), { status: 404 });
  const blocker = invoiceBlocker(order, seller);
  if (blocker) throw Object.assign(new Error(blocker), { status: 409 });
  const { invoice_number: number, invoice_date: date } = await ensureInvoiceNumber(orderId);
  const pos = resolveState(order.s_state) || seller.state; // unknown buyer state → treat as intra-state (conservative)
  const intraState = pos.code === seller.state.code;
  const [sub, disc, del, tax, total] = ['subtotal', 'discount', 'delivery_fee', 'tax_amount', 'total'].map((k) => parseFloat(order[k] || 0));
  const inclusive = !(tax > 0 && Math.abs(total - (sub - disc + del + tax)) < 0.02);
  const calc = computeInvoice({ items: order.items, discount: disc, deliveryFee: del, rate: seller.rate, intraState, inclusive });
  if (Math.abs(calc.totals.amount - total) > 0.05) console.warn(`[invoice] ${order.order_number}: invoice total ${calc.totals.amount} ≠ order total ${total}`);
  const fmt = (d) => new Date(d).toLocaleDateString('en-IN', { day: '2-digit', month: 'short', year: 'numeric', timeZone: 'Asia/Kolkata' });
  const pdf = await renderPdf({
    number, date: fmt(date), orderNumber: order.order_number, orderDate: fmt(order.created_at), seller, rate: seller.rate, intraState,
    placeOfSupply: pos, payment: `${order.payment_method}${order.payment_status === 'Paid' ? ' (Paid)' : ''}`,
    buyer: [order.s_name || order.customer_name, order.s_line1, order.s_line2, `${order.s_city || ''}, ${order.s_state || ''} - ${order.s_pincode || ''}`, order.s_phone ? `Phone: ${order.s_phone}` : null].filter(Boolean),
    ...calc,
  });
  return { pdf, number };
};

module.exports = { buildInvoicePdf, computeInvoice, amountInWords, financialYear, resolveState, getSellerSettings, invoiceBlocker, GSTIN_RE };
