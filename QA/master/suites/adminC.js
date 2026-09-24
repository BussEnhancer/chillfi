module.exports = async (b, { rec, shot }) => {
  const A = process.env.ADMIN_TOKEN, C = process.env.CUSTOMER_TOKEN, BASE = 'http://localhost:5200';
  const api = async (path, opts = {}, tok = A) => { const r = await fetch('http://localhost:5000/api' + path, { ...opts, headers: { 'Content-Type': 'application/json', ...(tok ? { Authorization: `Bearer ${tok}` } : {}), ...(opts.headers || {}) } }); const j = await r.json().catch(() => ({})); j.__status = r.status; return j; };
  const c = await b.newContext({ viewport: { width: 1440, height: 900 }, acceptDownloads: true });
  await c.addInitScript((t) => { localStorage.setItem('access_token', t); localStorage.setItem('refresh_token', 'none'); }, A);
  const p = await c.newPage(); p.errs = []; p.on('pageerror', (e) => p.errs.push(e.message));
  const go = async (path) => { await p.goto(BASE + path, { waitUntil: 'networkidle' }); await p.waitForTimeout(800); };
  const body = () => p.locator('body').innerText();
  // Orders
  await go('/admin/orders'); const ob = await body();
  rec('ADM-04-01', /CF\d{10}/.test(ob) && /115|116|117|total orders/.test(ob), 'orders list with numbers, customers, amounts', await shot(p, 'adm04_orders'));
  const dl = p.waitForEvent('download', { timeout: 8000 }).catch(() => null);
  await p.getByRole('button', { name: /export/i }).first().click().catch(() => {}); const d = await dl;
  let rows = 0; if (d) { const fs = require('fs'); const f = await d.path(); rows = fs.readFileSync(f, 'utf8').trim().split('\n').length - 1; }
  rec('ADM-04-02', rows > 50, `CSV rows=${rows}`);
  // order detail (delivered one with AWB)
  await p.locator('input[placeholder*="earch" i]').last().fill('CF4266319808'); await p.waitForTimeout(600);
  await p.locator('button[title*="View" i], button:has(svg.lucide-eye)').first().click(); await p.waitForTimeout(1000);
  const md = await body();
  rec('ADM-04-03', /CF4266319808/.test(md) && /86406910000140/.test(md) && /boAt/.test(md), 'modal: items, AWB, Delhivery section', await shot(p, 'adm04_modal'));
  rec('ADM-04-04b', /status is final/i.test(md), 'Delivered order: status editor locked (final)');
  // terminal guard via API
  const del = (await api('/admin/orders?limit=1000')).data.orders.find((o) => o.order_number === 'CF4266319808');
  const back = await api(`/admin/orders/${del.id}/status`, { method: 'PUT', body: JSON.stringify({ status: 'Processing' }) });
  rec('ADM-04-04', back.__status === 400, `Delivered → Processing via API: ${back.message}`);
  // live tracking + label
  const tr = await api(`/admin/orders/${del.id}/tracking`); rec('ADM-04-06', (tr.data?.scans || []).length > 0, `admin tracking scans=${(tr.data?.scans || []).length}`);
  const lb = await api(`/admin/orders/${del.id}/label`); rec('ADM-04-07', lb.__status === 200 && ('pdf_url' in (lb.data || {})), `label endpoint → ${lb.__status} pdf_url=${lb.data?.pdf_url ? 'present' : 'null (staging)'}`);
  await p.keyboard.press('Escape');
  // Refunds
  await go('/admin/refunds'); const rb = await body();
  const reqs = (await api('/admin/refund-requests?limit=100')).data.requests;
  rec('ADM-05-01', reqs.length > 0 && reqs.every((r) => rb.includes(r.order_number)), `refund requests listed: ${reqs.length} (page shows all=${reqs.every((r) => rb.includes(r.order_number))})`, await shot(p, 'adm05_refunds'));
  const target = reqs.find((r) => r.order_number === 'CF6508596040' && r.status === 'Requested') || reqs.find((r) => r.status === 'Requested');
  const ap = await api(`/admin/refund-requests/${target.id}`, { method: 'PUT', body: JSON.stringify({ status: 'Approved' }) });
  const rf = await api(`/admin/refund-requests/${target.id}`, { method: 'PUT', body: JSON.stringify({ status: 'Refunded' }) });
  const o2 = (await api(`/orders/${target.order_id}`, {}, C)).data?.order;
  const n = (await api('/profile/notifications?limit=5', {}, C)).data; const nl = n.notifications || n;
  rec('ADM-05-03', ap.success && nl.some((x) => /approved/i.test(x.title + x.body)), `approved; customer notified=${nl.some((x) => /approved/i.test(x.title + x.body))}`);
  rec('ADM-05-04', rf.success && o2?.payment_status === 'Refunded' && nl.some((x) => /Refund processed/i.test(x.title)), `Refunded → order payment_status ${o2?.payment_status}; notification=${nl.some((x) => /Refund processed/i.test(x.title))}`);
  const reopen = await api(`/admin/refund-requests/${target.id}`, { method: 'PUT', body: JSON.stringify({ status: 'Requested' }) });
  rec('ADM-05-04b', reopen.__status === 400, `refunded request can't be reopened: ${reopen.message}`);
  await go('/admin/refunds'); await p.getByRole('button', { name: /^refunded/i }).first().click().catch(() => {}); await p.waitForTimeout(800);
  rec('ADM-05-02', /Refunded/i.test(await body()), 'status filter works', await shot(p, 'adm05_filter'));
  // Users
  await go('/admin/users'); const ub = await body();
  rec('ADM-06-01', /DLV-TEST Customer/.test(ub), 'users listed', await shot(p, 'adm06_users'));
  const me = (await api('/auth/me', {}, C)).data.user;
  await api(`/admin/users/${me.id}/status`, { method: 'PUT', body: JSON.stringify({ status: 'Blocked' }) });
  const blocked = await api('/auth/me', {}, C);
  await api(`/admin/users/${me.id}/status`, { method: 'PUT', body: JSON.stringify({ status: 'Active' }) });
  const unblocked = await api('/auth/me', {}, C);
  rec('ADM-06-02', blocked.__status === 401 && unblocked.__status === 200, `blocked → customer API ${blocked.__status}; unblocked → ${unblocked.__status}`);
  rec('ADM-06-04', !/title="Remove"/.test(await p.content()), 'fake Remove button gone (Block/Unblock only)');
  rec('JS-ERRORS', p.errs.length === 0, `page errors: ${p.errs.slice(0, 3).join(' | ') || 'none'}`);
  await c.close();
};
