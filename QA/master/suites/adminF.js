// Admin suite F: shell (sidebar, header search, bell, logout), product filters, staff role, brand delete, broadcast.
const fs = require('fs');
module.exports = async (b, { rec, shot }) => {
  const A = process.env.ADMIN_TOKEN, BASE = 'http://localhost:5200';
  const [STAFF_ID, S] = fs.readFileSync('/tmp/cf_staff.txt', 'utf8').trim().split('\n');
  const api = async (path, opts = {}, tok = A) => { const r = await fetch('http://localhost:5000/api' + path, { ...opts, headers: { 'Content-Type': 'application/json', ...(tok ? { Authorization: `Bearer ${tok}` } : {}), ...(opts.headers || {}) } }); const j = await r.json().catch(() => ({})); j.__status = r.status; return j; };
  const J = (o) => ({ body: JSON.stringify(o) });
  const ctx = async (tok) => { const c = await b.newContext({ viewport: { width: 1440, height: 900 } }); await c.addInitScript((t) => { if (!sessionStorage.getItem('qa_seeded')) { localStorage.setItem('access_token', t); localStorage.setItem('refresh_token', 'none'); sessionStorage.setItem('qa_seeded', '1'); } }, tok); return c; };
  const c = await ctx(A);
  const p = await c.newPage(); p.errs = []; p.on('pageerror', (e) => p.errs.push(e.message));
  const go = async (path, pg = p) => { await pg.goto(BASE + path, { waitUntil: 'networkidle' }); await pg.waitForTimeout(800); };
  const body = (pg = p) => pg.locator('body').innerText();

  // Sidebar: every link navigates to its page without errors
  await go('/admin');
  const links = await p.locator('aside a[href^="/admin"]').evaluateAll((as) => as.map((a) => [a.textContent.trim(), a.getAttribute('href')]));
  const bad = [];
  for (const [label, href] of links) {
    await p.locator(`aside a[href="${href}"]`).first().click(); await p.waitForLoadState('networkidle'); await p.waitForTimeout(300);
    if (new URL(p.url()).pathname !== href || /404|not found/i.test((await body()).slice(0, 400))) bad.push(label);
  }
  rec('ADM-01-05', links.length >= 15 && !bad.length && !p.errs.length, `${links.length} sidebar links; broken: ${bad.join(',') || 'none'}; JS errors ${p.errs.length}`);

  // Header search (from another page and while already on Products)
  await go('/admin/orders');
  const hs = p.locator('header input[placeholder="Search products..."]');
  await hs.fill('Sony'); await hs.press('Enter'); await p.waitForTimeout(1200);
  const rows1 = await p.locator('tbody tr').allInnerTexts();
  await hs.fill('boAt'); await hs.press('Enter'); await p.waitForTimeout(1200);
  const rows2 = await p.locator('tbody tr').allInnerTexts();
  const pageSearch = await p.locator('main input[placeholder="Search products..."], input[placeholder="Search products..."]').last().inputValue();
  rec('ADM-01-06', p.url().includes('/admin/products?search=boAt') && rows1.length > 0 && rows1.every((r) => /sony/i.test(r)) && rows2.length > 0 && rows2.every((r) => /boat/i.test(r)) && pageSearch === 'boAt',
    `header search → products filtered (Sony ${rows1.length} rows, then boAt ${rows2.length} rows while on page; field="${pageSearch}")`, await shot(p, 'adm01_search'));

  // ADM-03-02: product page search + category filter
  const selects = p.locator('main select');
  let catOk = null;
  if (await selects.count()) {
    const opts = await selects.first().locator('option').allInnerTexts();
    const cat = opts.find((o) => /audio|headphone|speaker|mobile|laptop/i.test(o));
    await p.locator('main input[placeholder="Search products..."]').last().fill('');
    if (cat) { await selects.first().selectOption({ label: cat }); await p.waitForTimeout(600); const rr = await p.locator('tbody tr').allInnerTexts(); catOk = rr.length > 0 ? `${cat}: ${rr.length} rows` : `${cat}: 0 rows`; }
  }
  rec('ADM-03-02', catOk !== null && !/: 0 rows/.test(catOk), `search verified above; category filter → ${catOk}`);

  // Bell: real counts, each item navigates
  const alerts = (await api('/admin/alerts')).data;
  await go('/admin');
  const bell = p.locator('header button[aria-label*="attention"], header button[aria-label="Notifications"]').first();
  const badge = (await bell.innerText()).trim();
  await bell.click(); await p.waitForTimeout(400);
  const panel = await body();
  const labelsShown = alerts.items.every((i) => panel.includes(i.label));
  const bellShot = await shot(p, 'adm01_bell');
  let navOk = true;
  if (alerts.items[0]) { await p.getByText(alerts.items[0].label, { exact: true }).click(); await p.waitForTimeout(600); navOk = new URL(p.url()).pathname === alerts.items[0].to; }
  rec('ADM-01-07', labelsShown && String(alerts.total > 99 ? '99+' : alerts.total || '') === badge && navOk, `badge "${badge}" = ${alerts.total}; items: ${alerts.items.map((i) => `${i.key}=${i.count}`).join(', ')}; click → ${p.url().replace(BASE, '')}`, bellShot);

  // ADM-06-03: role toggle support staff (admin API), staff scope enforced
  const rr = await api(`/admin/users/${STAFF_ID}/role`, { method: 'PUT', ...J({ role: 'support_staff' }) });
  const sOrders = await api('/admin/orders?limit=1', {}, S);
  const sSettings = await api('/admin/settings', {}, S);
  const sStatus = await api('/admin/orders/00000000-0000-0000-0000-000000000000/status', { method: 'PUT', ...J({ status: 'Delivered' }) }, S);
  const sAlerts = (await api('/admin/alerts', {}, S)).data;
  const sc = await ctx(S); const sp = await sc.newPage();
  await go('/admin/orders', sp);
  const sideLabels = await sp.locator('aside a[href^="/admin"]').allInnerTexts();
  await sp.locator('header button').last().click(); await sp.waitForTimeout(300);
  const profileMenu = await body(sp);
  const staffShot = await shot(sp, 'adm06_staff');
  await go('/admin/settings', sp); const settingsUrl = sp.url();
  await sc.close();
  const staffOk = rr.success && sOrders.__status === 200 && sSettings.__status === 403 && sStatus.__status === 403 && !sAlerts.items.some((i) => ['open_refunds', 'low_stock'].includes(i.key)) && !sideLabels.some((l) => /Settings|Products|Users/.test(l)) && !/Settings/.test(profileMenu.split('Logout')[0].slice(-40)) && new URL(settingsUrl).pathname === '/admin/orders';
  rec('ADM-06-03', staffOk, `role→support_staff ${rr.success}; staff: orders ${sOrders.__status}, settings ${sSettings.__status}, update status ${sStatus.__status}; sidebar=[${sideLabels.join('|')}]; /admin/settings → ${settingsUrl.replace(BASE, '')} (expect redirect to /admin/orders)`, staffShot);
  await api(`/admin/users/${STAFF_ID}/role`, { method: 'PUT', ...J({ role: 'customer' }) });

  // ADM-08-04: brand delete (QA Brand)
  const qb = ((await api('/admin/brands')).data.brands || []).find((x) => x.name === 'QA Brand');
  if (qb) {
    const d = await api(`/admin/brands/${qb.id}`, { method: 'DELETE' });
    const still = ((await api('/admin/brands')).data.brands || []).find((x) => x.id === qb.id);
    const pub = ((await api('/brands', {}, null)).data.brands || []).some((x) => x.id === qb.id);
    rec('ADM-08-04', d.__status < 500 && !pub, `delete QA Brand → ${d.__status} "${d.message}"; still in admin=${!!still}${still ? ` (active=${still.is_active})` : ''}; on storefront=${pub}`);
  } else rec('ADM-08-04', false, 'QA Brand not found');

  // ADM-11-03: broadcast (local users only)
  await go('/admin/notifications');
  const ui = await body();
  const bc = await api('/admin/notify', { method: 'POST', ...J({ title: 'QA broadcast', body: 'Local QA broadcast test' }) });
  const inbox = (await api('/profile/notifications?limit=5', {}, process.env.CUSTOMER_TOKEN)).data; const il = inbox.notifications || inbox;
  rec('ADM-11-03', bc.success && il.some((x) => x.title === 'QA broadcast'), `broadcast → ${bc.message}; customer inbox has it=${il.some((x) => x.title === 'QA broadcast')}; UI offers all-users option=${/All Customers/i.test(ui)}`, await shot(p, 'adm11_broadcast'));

  // ADM-01-08: logout clears session and guards admin routes
  await go('/admin');
  await p.locator('header button').last().click(); await p.waitForTimeout(300);
  await p.getByRole('button', { name: /Logout/ }).click(); await p.waitForTimeout(1000);
  const afterLogout = p.url();
  const tokenLeft = await p.evaluate(() => localStorage.getItem('access_token'));
  await go('/admin/orders'); const guarded = p.url();
  rec('ADM-01-08', /\/login/.test(afterLogout) && !tokenLeft && !/\/admin/.test(new URL(guarded).pathname), `logout → ${afterLogout.replace(BASE, '')}; token cleared=${!tokenLeft}; /admin/orders afterwards → ${guarded.replace(BASE, '')}`, await shot(p, 'adm01_logout'));
  rec('ADM-XX-JS-F', p.errs.length === 0, `page errors: ${p.errs.slice(0, 3).join(' | ') || 'none'}`);
  await c.close();
};
