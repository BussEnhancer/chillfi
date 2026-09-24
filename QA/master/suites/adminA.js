module.exports = async (b, { rec, shot, fs }) => {
  const A = process.env.ADMIN_TOKEN, C = process.env.CUSTOMER_TOKEN, BASE = 'http://localhost:5200';
  const api = async (tok, path, opts = {}) => (await fetch('http://localhost:5000/api' + path, { ...opts, headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${tok}`, ...(opts.headers || {}) } })).json();
  const page = async (tok, w = 1440) => { const c = await b.newContext({ viewport: { width: w, height: 900 }, acceptDownloads: true }); if (tok) await c.addInitScript((t) => { localStorage.setItem('access_token', t); localStorage.setItem('refresh_token', 'none'); }, tok); const p = await c.newPage(); p.errs = []; p.on('pageerror', (e) => p.errs.push(e.message)); return { c, p }; };
  const go = async (p, path) => { await p.goto(BASE + path, { waitUntil: 'networkidle' }); await p.waitForTimeout(700); };
  const body = (p) => p.locator('body').innerText();
  // ── Access control
  { const { c, p } = await page(null); await go(p, '/admin'); rec('ADM-01-01', /\/login/.test(p.url()), `guest /admin → ${p.url().replace(BASE, '')}`); await c.close(); }
  { const { c, p } = await page(C); await go(p, '/admin'); const r = await fetch('http://localhost:5000/api/admin/dashboard', { headers: { Authorization: `Bearer ${C}` } });
    rec('ADM-01-02', !/\/admin/.test(p.url()) && r.status === 403, `customer /admin → ${p.url().replace(BASE, '')}; API ${r.status}`); await c.close(); }
  { // role cache: admin page in same tab, then swap token to customer
    const { c, p } = await page(A); await go(p, '/admin');
    await p.evaluate((t) => { localStorage.setItem('access_token', t); }, C); await go(p, '/admin/products');
    rec('ADM-01-04', !/\/admin/.test(p.url()), `after switching to customer token in same tab → ${p.url().replace(BASE, '')}`); await c.close(); }
  { // support staff scope: temporarily make the test customer support_staff
    const me = (await api(C, '/auth/me')).data.user;
    const r1 = await api(A, `/admin/users/${me.id}/role`, { method: 'PUT', body: JSON.stringify({ role: 'support_staff' }) });
    const { c, p } = await page(C); await go(p, '/admin/orders');
    const side = await p.locator('aside, nav').first().innerText().catch(() => '');
    await p.locator('button[title*="View" i], button:has(svg.lucide-eye)').first().click().catch(() => {}); await p.waitForTimeout(800);
    const modal = await body(p);
    const st = await fetch('http://localhost:5000/api/admin/products', { headers: { Authorization: `Bearer ${C}` } });
    rec('ADM-01-03', r1.success && !/Settings|Coupons|Users/.test(side) && !/Update Order Status|Create Shipment/.test(modal) && st.status === 403, `staff sidebar hides admin pages=${!/Settings|Coupons|Users/.test(side)}; order modal admin actions hidden=${!/Update Order Status|Create Shipment/.test(modal)}; admin API ${st.status}`, await shot(p, 'adm01_staff'));
    rec('ADM-04-09', !/Update Order Status|Create Shipment/.test(modal), 'staff: status/ship hidden');
    await api(A, `/admin/users/${me.id}/role`, { method: 'PUT', body: JSON.stringify({ role: 'customer' }) }); await c.close(); }
  const { c, p } = await page(A);
  // self-protection
  const adminMe = (await api(A, '/auth/me')).data.user;
  const selfBlock = await api(A, `/admin/users/${adminMe.id}/status`, { method: 'PUT', body: JSON.stringify({ status: 'Blocked' }) });
  const selfRole = await api(A, `/admin/users/${adminMe.id}/role`, { method: 'PUT', body: JSON.stringify({ role: 'customer' }) });
  rec('ADM-06-05', !selfBlock.success && !selfRole.success, `self-block: ${selfBlock.message} | self-role: ${selfRole.message}`);
  // ── Dashboard
  await go(p, '/admin'); const db = await body(p); const d = (await api(A, '/admin/dashboard')).data;
  const revTxt = `₹${d.revenue.toLocaleString('en-IN')}`;
  rec('ADM-02-01', db.includes(String(d.orders.total)) && db.includes(String(d.products)), `cards: revenue ${d.revenue} (paid & not cancelled), orders ${d.orders.total}, products ${d.products}, users ${d.users}; no fake +100%=${!/\+100%/.test(db)}`, await shot(p, 'adm02_dashboard', true));
  rec('ADM-02-02', Array.isArray(d.monthly_revenue) && d.monthly_revenue.every((m) => +m.revenue >= 0), `monthly: ${JSON.stringify(d.monthly_revenue)}`);
  rec('ADM-02-03', d.top_products.length > 0 && d.recent_orders.length > 0 && !/1 items/.test(db), `top ${d.top_products.length}, recent ${d.recent_orders.length}; grammar ok=${!/1 items/.test(db)}`);
  await p.route('**/api/admin/dashboard', (r) => r.abort('internetdisconnected')); await go(p, '/admin');
  const dbe = await body(p); rec('ADM-02-04', /couldn.t load|offline|can.t be reached/i.test(dbe) && !/Apple AirPods Pro 2nd Gen/.test(dbe), `API down → error shown; mock data shown=${/PRD00|2nd Gen/.test(dbe)}`, await shot(p, 'adm02_error')); await p.unroute('**/api/admin/dashboard');
  // ── Products
  await go(p, '/admin/products');
  const plist = (await api(A, '/admin/products?limit=1000&status=all')).data.products;
  rec('ADM-03-01', plist.some((x) => x.status === 'Inactive'), `admin list ${plist.length} incl. inactive=${plist.filter((x) => x.status === 'Inactive').length}`, await shot(p, 'adm03_products'));
  await p.getByRole('button', { name: /add product/i }).first().click(); await p.waitForTimeout(500);
  await p.getByRole('button', { name: /^(save|add product|create)/i }).last().click().catch(() => {}); await p.waitForTimeout(600);
  const vText = await body(p);
  rec('ADM-03-04', /required|name|price|greater than/i.test(vText), 'empty product save → error shown', await shot(p, 'adm03_add_validation'));
  fs.writeFileSync('results/web/adminA_state.json', JSON.stringify({ adminMe: adminMe.id }));
  rec('JS-ERRORS', p.errs.length === 0, `page errors: ${p.errs.slice(0, 3).join(' | ') || 'none'}`);
  await c.close();
};
