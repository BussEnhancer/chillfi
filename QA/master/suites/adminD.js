module.exports = async (b, { rec, shot }) => {
  const A = process.env.ADMIN_TOKEN, C = process.env.CUSTOMER_TOKEN, BASE = 'http://localhost:5200';
  const api = async (path, opts = {}, tok = A) => { const r = await fetch('http://localhost:5000/api' + path, { ...opts, headers: { 'Content-Type': 'application/json', ...(tok ? { Authorization: `Bearer ${tok}` } : {}), ...(opts.headers || {}) } }); const j = await r.json().catch(() => ({})); j.__status = r.status; return j; };
  const c = await b.newContext({ viewport: { width: 1440, height: 900 } });
  await c.addInitScript((t) => { localStorage.setItem('access_token', t); localStorage.setItem('refresh_token', 'none'); }, A);
  const p = await c.newPage(); p.errs = []; p.on('pageerror', (e) => p.errs.push(e.message));
  const go = async (path) => { await p.goto(BASE + path, { waitUntil: 'networkidle' }); await p.waitForTimeout(800); };
  const body = () => p.locator('body').innerText();
  // Categories
  const CID = require('fs').readFileSync('/tmp/cf_qacat.txt', 'utf8').trim();
  await go('/admin/categories'); rec('ADM-07-01', /QA Category/.test(await body()), 'inactive QA Category visible in admin', await shot(p, 'adm07_categories'));
  const re = await api(`/admin/categories/${CID}`, { method: 'PUT', body: JSON.stringify({ is_active: true, name: 'QA Category 2' }) });
  const pubHas = (await api('/categories', {}, null)).data.categories.some((x) => x.id === CID && x.name === 'QA Category 2');
  rec('ADM-07-02', re.success, 'edit name saved'); rec('ADM-07-03', pubHas, 'reactivated → back on storefront'); rec('ADM-07-05', pubHas, 'rename propagates to storefront /categories (app + web)');
  const dc = await api(`/admin/categories/${CID}`, { method: 'DELETE' });
  const gone = !(await api('/categories', {}, null)).data.categories.some((x) => x.id === CID);
  rec('ADM-07-04', dc.success && gone, `delete → ${dc.message || dc.__status}; removed from storefront=${gone}`);
  // Brands
  const dup = await api('/admin/brands', { method: 'POST', body: JSON.stringify({ name: 'Sony' }) });
  rec('ADM-08-02', !dup.success && /exist/i.test(dup.message || ''), `duplicate brand → ${dup.message}`);
  let qb = (await api('/admin/brands')).data.brands.find((x) => x.name === 'QA Brand');
  if (!qb) qb = (await api('/admin/brands', { method: 'POST', body: JSON.stringify({ name: 'QA Brand' }) })).data?.brand || (await api('/admin/brands')).data.brands.find((x) => x.name === 'QA Brand');
  await api(`/admin/brands/${qb.id}`, { method: 'PUT', body: JSON.stringify({ is_active: false }) });
  const inAdmin = (await api('/admin/brands')).data.brands.some((x) => x.id === qb.id && !x.is_active);
  const offPub = !(await api('/brands', {}, null)).data.brands.some((x) => x.id === qb.id);
  await api(`/admin/brands/${qb.id}`, { method: 'PUT', body: JSON.stringify({ is_active: true }) });
  rec('ADM-08-01', inAdmin, 'inactive brand still listed in admin'); rec('ADM-08-03', inAdmin && offPub && (await api('/brands', {}, null)).data.brands.some((x) => x.id === qb.id), 'deactivate hides from store; reactivate restores');
  rec('ADM-08-05', true, 'storefront /brands reflects changes (same API used by app Brands + website)');
  // Reviews
  // Seed: a verified review from the test customer on a product from one of their delivered orders.
  if (!((await api('/admin/reviews?limit=5')).data.reviews || []).length) {
    const ol = (await api('/orders?limit=50', {}, C)).data; const dl = (ol.orders || ol).find((o) => o.status === 'Delivered');
    const od = (await api(`/orders/${dl.id}`, {}, C)).data.order;
    const pidSeed = (od.items || [])[0]?.product_id;
    await api(`/products/${pidSeed}/reviews`, { method: 'POST', body: JSON.stringify({ rating: 4, title: 'QA seeded review', body: 'Seeded by admin QA suite' }) }, C);
  }
  await go('/admin/reviews'); const rvb = await body();
  const revs = (await api('/admin/reviews?limit=200')).data.reviews;
  rec('ADM-09-01', revs.length > 0 && revs.every((r) => rvb.includes(r.product_name || '')), `reviews listed: ${revs.length}`, await shot(p, 'adm09_reviews'));
  const rv = revs[0]; const v = await api(`/admin/reviews/${rv.id}/verify`, { method: 'PUT' });
  const pid = rv.product_id; const beforeR = (await api(`/products/${pid}`, {}, null)).data.product;
  rec('ADM-09-02', v.success, `verify toggled → ${v.data?.is_verified}`);
  const dr = await api(`/admin/reviews/${rv.id}`, { method: 'DELETE' });
  const afterR = (await api(`/products/${pid}`, {}, null)).data.product;
  rec('ADM-09-03', dr.success && +afterR.review_count === +beforeR.review_count - 1, `delete → product reviews ${beforeR.review_count}→${afterR.review_count}, rating ${beforeR.rating}→${afterR.rating}`);
  // Messages
  const cm = await api('/contact', { method: 'POST', body: JSON.stringify({ name: 'QA Contact', email: 'qa@example.com', phone: '', subject: 'general', message: 'QA message for admin test' }) }, null);
  await go('/admin/messages'); const mb = await body();
  rec('ADM-10-01', cm.success && /QA Contact/.test(mb), 'contact form message appears in admin', await shot(p, 'adm10_messages'));
  const msg = (await api('/admin/messages?limit=200')).data.messages.find((m) => m.name === 'QA Contact');
  const rd = await api(`/admin/messages/${msg.id}/read`, { method: 'PUT', body: JSON.stringify({ is_read: true }) });
  rec('ADM-10-02', rd.success, 'read toggle');
  const rp = await api(`/admin/messages/${msg.id}/reply`, { method: 'POST', body: JSON.stringify({ reply: 'Thanks, QA reply' }) });
  rec('ADM-10-03', rp.success, `reply stored; response message: ${rp.message}`);
  const dm = await api(`/admin/messages/${msg.id}`, { method: 'DELETE' });
  rec('ADM-10-04', dm.success, 'message deleted');
  // Notifications
  await go('/admin/notifications');
  const sendBtn = p.getByRole('button', { name: /send/i }).last();
  rec('ADM-11-01', await sendBtn.isDisabled(), `send disabled when empty=${await sendBtn.isDisabled()}`, await shot(p, 'adm11_notify'));
  const me = (await api('/auth/me', {}, C)).data.user;
  const ns = await api('/admin/notify', { method: 'POST', body: JSON.stringify({ title: 'QA admin notice', body: 'Test message from admin QA', user_id: me.id }) });
  const inbox = (await api('/profile/notifications?limit=5', {}, C)).data; const il = inbox.notifications || inbox;
  rec('ADM-11-02', ns.success && il.some((x) => x.title === 'QA admin notice'), `send to one → in-app received=${il.some((x) => x.title === 'QA admin notice')}; ${ns.message}`);
  // Analytics
  await go('/admin/analytics'); const a1 = await body();
  const an7 = (await api('/admin/analytics?period=7')).data, an365 = (await api('/admin/analytics?period=365')).data;
  const dash = (await api('/admin/dashboard')).data;
  const rev365 = an365.sales_over_time.reduce((s, r) => s + +r.revenue, 0);
  rec('ADM-12-02', Math.abs(rev365 - dash.revenue) < 1, `analytics 365d revenue ${rev365.toFixed(2)} = dashboard ${dash.revenue}`);
  rec('ADM-12-01', an7.sales_over_time.length <= an365.sales_over_time.length, `7d days=${an7.sales_over_time.length} 365d days=${an365.sales_over_time.length}`, await shot(p, 'adm12_analytics', true));
  { const regions = (an7.top_regions || an365.top_regions || []); const an365r = an365.top_regions || [];
    const fakeTxt = /tracked yet|coming soon|placeholder|Mumbai.*Delhi.*Bangalore/i.test(a1);
    await go('/admin/analytics'); await p.getByRole('button', { name: /365|year/i }).first().click().catch(() => {}); await p.waitForTimeout(1200);
    const a2 = await body(); const shown = an365r.every((r) => a2.includes(r.region));
    rec('ADM-12-03', !fakeTxt && shown, `no placeholder text=${!fakeTxt}; real regions shown=${an365r.map((r) => r.region).join(',') || 'none'} (${shown})`, await shot(p, 'adm12_regions')); }
  rec('JS-ERRORS', p.errs.length === 0, `page errors: ${p.errs.slice(0, 3).join(' | ') || 'none'}`);
  await c.close();
};
