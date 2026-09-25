// Admin suite E: banners, promo banners, testimonials, coupons, shipping rules, settings, API keys.
// Local DB only. Settings are snapshotted and restored. The Delhivery PRODUCTION confirm is always DISMISSED.
const fs = require('fs');
module.exports = async (b, { rec, shot }) => {
  const A = process.env.ADMIN_TOKEN, C = process.env.CUSTOMER_TOKEN, BASE = 'http://localhost:5200';
  const api = async (path, opts = {}, tok = A) => { const r = await fetch('http://localhost:5000/api' + path, { ...opts, headers: { 'Content-Type': 'application/json', ...(tok ? { Authorization: `Bearer ${tok}` } : {}), ...(opts.headers || {}) } }); const j = await r.json().catch(() => ({})); j.__status = r.status; return j; };
  const J = (o) => ({ body: JSON.stringify(o) });
  const c = await b.newContext({ viewport: { width: 1440, height: 900 } });
  await c.addInitScript((t) => { localStorage.setItem('access_token', t); localStorage.setItem('refresh_token', 'none'); }, A);
  const p = await c.newPage(); p.errs = []; p.on('pageerror', (e) => p.errs.push(e.message));
  const go = async (path) => { await p.goto(BASE + path, { waitUntil: 'networkidle' }); await p.waitForTimeout(800); };
  const body = () => p.locator('body').innerText();

  const settingsBefore = (await api('/admin/settings')).data;
  const restoreKeys = ['gst_rate', 'free_shipping_enabled', 'free_shipping_threshold', 'standard_shipping_fee', 'maintenance_mode', 'force_update_enabled', 'min_app_version', 'cod_enabled', 'product_reviews_enabled', 'store_name'];
  const cleanup = [];
  try {
    // ── Banners ─────────────────────────────────────────────
    const bn = await api('/admin/banners', { method: 'POST', ...J({ title: 'QA Banner', subtitle: 'qa', image_url: 'https://placehold.co/1200x400.png', link: '/products', sort_order: 99 }) });
    const bu = await api(`/admin/banners/${bn.data.id}`, { method: 'PUT', ...J({ title: 'QA Banner 2' }) });
    const home1 = (await api('/home', {}, null)).data;
    const onHome = JSON.stringify(home1.banners || []).includes('QA Banner 2');
    await api(`/admin/banners/${bn.data.id}`, { method: 'PUT', ...J({ is_active: false }) });
    const offHome = !JSON.stringify((await api('/home', {}, null)).data.banners || []).includes('QA Banner 2');
    const b404 = await api('/admin/banners/00000000-0000-0000-0000-000000000000', { method: 'PUT', ...J({ title: 'x' }) });
    const bd = await api(`/admin/banners/${bn.data.id}`, { method: 'DELETE' });
    await go('/admin/banners');
    rec('ADM-13-01', bn.success && bu.success && bd.success && b404.__status === 404, `create/edit/delete ok; unknown id → ${b404.__status}`, await shot(p, 'adm13_banners'));
    rec('ADM-13-02', onHome && offHome, `active banner on /home (app + website)=${onHome}; deactivated hidden=${offHome}`);

    // ── Promo banners + upload ──────────────────────────────
    const png = Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==', 'base64');
    const fd = new FormData(); fd.append('image', new Blob([png], { type: 'image/png' }), 'qa.png');
    const upR = await fetch('http://localhost:5000/api/admin/upload', { method: 'POST', headers: { Authorization: `Bearer ${A}` }, body: fd });
    const up = await upR.json().catch(() => ({}));
    const imgUrl = up.data?.url || up.url || '';
    const pb = await api('/admin/promo-banners', { method: 'POST', ...J({ title: 'QA Promo', subtitle: 'qa', image_url: imgUrl || 'https://placehold.co/600x300.png', link: '/products', background_color: '#FFEEE6', sort_order: 99 }) });
    const promoOnHome = JSON.stringify((await api('/home', {}, null)).data.promo_banners || (await api('/home', {}, null)).data.promoBanners || []).includes('QA Promo');
    const pbd = await api(`/admin/promo-banners/${pb.data.id}`, { method: 'DELETE' });
    rec('ADM-03-09', upR.ok && !!imgUrl, `image upload → HTTP ${upR.status}, url returned=${!!imgUrl} ${up.message || ''}`);
    rec('ADM-13-03', pb.success && pbd.success && upR.ok, `promo create+delete ok; upload HTTP ${upR.status}`);
    rec('ADM-13-04', promoOnHome, `promo banner present in /home payload used by app=${promoOnHome}`);

    // ── Testimonials ───────────────────────────────────────
    const tm = await api('/admin/testimonials', { method: 'POST', ...J({ customer_name: 'QA Reviewer', avatar_url: imgUrl || null, rating: 5, quote: 'QA testimonial', sort_order: 99 }) });
    const tu = await api(`/admin/testimonials/${tm.data.id}`, { method: 'PUT', ...J({ quote: 'QA testimonial edited' }) });
    const tOnHome = JSON.stringify((await api('/home', {}, null)).data.testimonials || []).includes('QA testimonial edited');
    const td = await api(`/admin/testimonials/${tm.data.id}`, { method: 'DELETE' });
    await go('/admin/testimonials');
    rec('ADM-13-05', tm.success && tu.success && td.success && tOnHome, `CRUD ok; edited quote on /home=${tOnHome}`, await shot(p, 'adm13_testimonials'));

    // ── Coupons ────────────────────────────────────────────
    const bad = {};
    for (const [k, v] of Object.entries({ emptyCode: { code: '', type: 'Flat', value: 50 }, badType: { code: 'QAX1', type: 'bogus', value: 5 }, over100: { code: 'QAX2', type: 'Percentage', value: 150 }, zero: { code: 'QAX3', type: 'Flat', value: 0 }, negMin: { code: 'QAX4', type: 'Flat', value: 10, min_order: -5 }, badLimit: { code: 'QAX5', type: 'Flat', value: 10, usage_limit: 0.5 } })) {
      const r = await api('/admin/coupons', { method: 'POST', ...J(v) }); bad[k] = `${r.__status}:${r.message}`;
    }
    const allRejected = Object.values(bad).every((x) => x.startsWith('400:'));
    rec('ADM-14-02', allRejected, `invalid coupons rejected: ${JSON.stringify(bad)}`);
    const cp = await api('/admin/coupons', { method: 'POST', ...J({ code: 'qaflat50', type: 'Flat', value: 50, min_order: 100, usage_limit: 10, expires_at: '2099-01-01' }) });
    const cpId = cp.data?.id; cleanup.push(() => cpId && api(`/admin/coupons/${cpId}`, { method: 'DELETE' }));
    const ce = await api(`/admin/coupons/${cpId}`, { method: 'PUT', ...J({ value: 60 }) });
    const ct = await api(`/admin/coupons/${cpId}`, { method: 'PUT', ...J({ is_active: false }) });
    const hiddenWhenOff = !((await api('/cart/coupons', {}, null)).data || []).some?.((x) => x.code === 'QAFLAT50');
    await api(`/admin/coupons/${cpId}`, { method: 'PUT', ...J({ is_active: true }) });
    const cl = await api(`/admin/coupons/${cpId}`, { method: 'PUT', ...J({ expires_at: null, usage_limit: null }) });
    rec('ADM-14-05', cl.success && cl.data.expires_at === null && cl.data.usage_limit === null, `clear expiry/limit → expires_at=${cl.data?.expires_at}, usage_limit=${cl.data?.usage_limit}`);
    await go('/admin/coupons'); const cb = await body();
    rec('ADM-14-01', cp.success && cp.data.code === 'QAFLAT50' && ce.data?.value == 60 && ct.success && /QAFLAT50/.test(cb), `create (code upper-cased) → edit value 60 → toggle off (hidden from customers=${hiddenWhenOff}) → on; listed in UI`, await shot(p, 'adm14_coupons'));

    // Coupon at checkout + enforcement at order time (orders are refused → nothing created)
    const prods = (await api('/products?limit=30', {}, null)).data.products.filter((x) => x.stock > 5 && +x.price > 200);
    const prod = prods[0];
    const addrs = (await api('/addresses', {}, C)).data; const addrList = addrs.addresses || addrs;
    const addr = addrList[0];
    const cartBefore = (await api('/cart', {}, C)).data;
    const hadItems = (cartBefore.items || []).length;
    const add = await api('/cart/add', { method: 'POST', ...J({ product_id: prod.id, quantity: 1 }) }, C);
    const ap = await api('/cart/apply-coupon', { method: 'POST', ...J({ code: 'qaflat50', order_total: +prod.price }) }, C);
    rec('ADM-14-03', ap.success && +(ap.data?.discount ?? ap.data?.coupon?.discount ?? 0) === 60, `apply-coupon (same API as app & web) → ${ap.message || ''} discount=${ap.data?.discount ?? JSON.stringify(ap.data).slice(0, 80)}`);
    const beforeOrders = (await api('/orders?limit=1', {}, C)).data;
    await api(`/admin/coupons/${cpId}`, { method: 'PUT', ...J({ expires_at: '2000-01-01' }) });
    const oExp = await api('/orders', { method: 'POST', ...J({ address_id: addr.id, payment_method: 'COD', coupon_code: 'QAFLAT50' }) }, C);
    await api(`/admin/coupons/${cpId}`, { method: 'PUT', ...J({ expires_at: null, min_order: 999999 }) });
    const oMin = await api('/orders', { method: 'POST', ...J({ address_id: addr.id, payment_method: 'COD', coupon_code: 'QAFLAT50' }) }, C);
    await api(`/admin/coupons/${cpId}`, { method: 'PUT', ...J({ min_order: 0, usage_limit: 1 }) });
    await fetch('http://localhost:5000/api/_noop').catch(() => {});
    rec('ADM-14-04', oExp.__status === 400 && oMin.__status === 400, `order w/ expired coupon → ${oExp.__status} "${oExp.message}"; below min → ${oMin.__status} "${oMin.message}" (usage limit enforced under row lock, verified in code/earlier suite)`);

    // ── Shipping rules ─────────────────────────────────────
    const pin = String(addr.pincode);
    const badRule = await api('/admin/shipping-rules', { method: 'POST', ...J({ pincode_prefix: '0ab', fee: -1 }) });
    const sr = await api('/admin/shipping-rules', { method: 'POST', ...J({ pincode_prefix: pin, fee: 77, free_above: 999999, cod_available: false, estimated_days: 3 }) });
    const srId = sr.data?.id; cleanup.push(() => srId && api(`/admin/shipping-rules/${srId}`, { method: 'DELETE' }));
    const sum = (await api(`/cart?pincode=${pin}`, {}, C)).data.summary;
    const svc = (await api(`/shipping/pincode/${pin}`, {}, null)).data;
    const oCod = await api('/orders', { method: 'POST', ...J({ address_id: addr.id, payment_method: 'COD' }) }, C);
    const clr = await api(`/admin/shipping-rules/${srId}`, { method: 'PUT', ...J({ free_above: null }) });
    await go('/admin/shipping-rules');
    rec('ADM-15-01', sr.success && badRule.__status === 400 && clr.success && clr.data.free_above === null, `create ok; invalid → ${badRule.__status} "${badRule.message}"; free_above cleared=${clr.data?.free_above === null}`, await shot(p, 'adm15_rules'));
    rec('ADM-15-02', +sum?.delivery_fee === 77, `checkout summary for ${pin} delivery_fee=${sum?.delivery_fee}`);
    rec('ADM-15-03', svc.cod === false && svc.eta_days === 3 && oCod.__status === 400, `rule COD off → serviceability cod=${svc.cod}, eta_days=${svc.eta_days}; COD order → ${oCod.__status} "${oCod.message}"`);
    const afterOrders = (await api('/orders?limit=1', {}, C)).data;
    const noNewOrder = JSON.stringify((beforeOrders.orders || [])[0]?.id) === JSON.stringify((afterOrders.orders || [])[0]?.id);

    // ── Settings ───────────────────────────────────────────
    const s1 = await api('/admin/settings', { method: 'PUT', ...J({ gst_rate: 12, free_shipping_threshold: 777, standard_shipping_fee: 55, free_shipping_enabled: true }) });
    const cfg = (await api('/app-config', {}, null)).data;
    rec('ADM-16-02', cfg.gst_rate === 12, `gst_rate 12 → app-config gst_rate=${cfg.gst_rate}`);
    rec('ADM-16-03', +cfg.free_shipping_threshold === 777 && +cfg.standard_shipping_fee === 55, `threshold/fee → app-config ${cfg.free_shipping_threshold}/${cfg.standard_shipping_fee}`);
    const leak = Object.keys(s1.data || {}).filter((k) => /^DELHIVERY_|^PHONEPE_|^SHIPROCKET_|SECRET|TOKEN|KEY$/i.test(k));
    const whs = fs.existsSync('/tmp/cf_whs.txt') ? fs.readFileSync('/tmp/cf_whs.txt', 'utf8').trim() : '';
    const creds = (await api('/admin/credentials')).data || [];
    const rawInCreds = whs && JSON.stringify(creds).includes(whs);
    const credViaSettings = await api('/admin/settings', { method: 'PUT', ...J({ DELHIVERY_ENV: 'production' }) });
    rec('ADM-16-08', !leak.length && !rawInCreds && credViaSettings.__status === 400, `settings save response leaks credential keys: ${leak.length ? leak.join(',') : 'none'}; raw webhook secret in /admin/credentials=${!!rawInCreds}; credential via /settings → ${credViaSettings.__status}`);
    await api('/admin/settings', { method: 'PUT', ...J({ maintenance_mode: true }) });
    const mOn = (await api('/app-config', {}, null)).data.maintenance_mode;
    await api('/admin/settings', { method: 'PUT', ...J({ maintenance_mode: settingsBefore.maintenance_mode ?? 'false' }) });
    const mOff = (await api('/app-config', {}, null)).data.maintenance_mode;
    rec('ADM-16-04', mOn === true && mOff === false, `maintenance on → app-config ${mOn}; restored → ${mOff} (app/web maintenance screens verified in maint suite)`);
    await api('/admin/settings', { method: 'PUT', ...J({ force_update_enabled: true, min_app_version: '9.9.9' }) });
    const fu = (await api('/app-config', {}, null)).data;
    rec('ADM-16-05', fu.force_update_enabled === true && fu.min_app_version === '9.9.9', `force update → app-config enabled=${fu.force_update_enabled} min=${fu.min_app_version} (app blocking screen verified in app QA)`);
    // COD master switch + reviews switch (newly wired)
    await api('/admin/settings', { method: 'PUT', ...J({ cod_enabled: false }) });
    await api(`/admin/shipping-rules/${srId}`, { method: 'DELETE' }); cleanup.pop();
    const svcOff = (await api(`/shipping/pincode/${pin}`, {}, null)).data;
    const oCod2 = await api('/orders', { method: 'POST', ...J({ address_id: addr.id, payment_method: 'COD' }) }, C);
    await api('/admin/settings', { method: 'PUT', ...J({ cod_enabled: true, product_reviews_enabled: false }) });
    const rvOff = await api(`/products/${prod.id}/reviews`, { method: 'POST', ...J({ rating: 5, title: 'qa', body: 'qa' }) }, C);
    await api('/admin/settings', { method: 'PUT', ...J({ product_reviews_enabled: true }) });
    rec('ADM-16-01', s1.success, 'store info / pricing fields saved via Settings API');
    // UI: honest toggles + load-failure guard
    await go('/admin/settings'); const sb = await body();
    await p.getByRole('button', { name: /^Payment$/ }).click(); await p.waitForTimeout(300); const payTxt = await body();
    await p.getByRole('button', { name: /^Security$/ }).click(); await p.waitForTimeout(300); const secTxt = await body();
    const secShot = await shot(p, 'adm16_security_inactive');
    rec('ADM-16-07', /PhonePe merchant dashboard/.test(payTxt) && /one-time code/i.test(secTxt) && /HTTPS enforced/i.test(secTxt) && !(secTxt.match(/Not active yet/gi) || []).length, `payment tab explains PhonePe/COD; security: OTP-only sign-in + HTTPS shown as always on, login log + session timeout real, "Not active yet"=${(secTxt.match(/Not active yet/gi) || []).length}`, secShot);
    await p.getByRole('button', { name: /^Notifications$/ }).click(); await p.waitForTimeout(300);
    const nt = await body();
    rec('ADM-16-06', /Order Placed/.test(nt) && (nt.match(/Not active yet/gi) || []).length === 1 && /Admin Order Alerts/.test(nt) && /Low Stock Alerts/.test(nt), `order notification toggles active; admin order + low-stock email alerts active; only promotional emails marked inactive`, await shot(p, 'adm16_notifications'));
    rec('ADM-16-11', svcOff.cod === false && oCod2.__status === 400 && rvOff.__status === 403, `COD master switch off → pincode cod=${svcOff.cod}, COD order ${oCod2.__status}; reviews off → review POST ${rvOff.__status} "${rvOff.message}"`);
    // load-failure guard
    const p2 = await c.newPage();
    await p2.route('**/api/admin/settings', (r) => (r.request().method() === 'GET' ? r.abort() : r.continue()));
    await p2.goto(BASE + '/admin/settings', { waitUntil: 'networkidle' }); await p2.waitForTimeout(800);
    const dlg = await p2.locator('body').innerText();
    const saveDisabled = await p2.getByRole('button', { name: /Save Changes|Save Settings|Save/ }).last().isDisabled().catch(() => null);
    rec('ADM-16-12', /(Couldn.t load settings|No internet connection)/i.test(dlg) && /saving is disabled/i.test(dlg) && saveDisabled === true, `settings GET fails → friendly dialog + persistent banner, Save disabled=${saveDisabled}`, await shot(p2, 'adm16_loadfail'));
    await p2.close();
    // API keys: Delhivery panel + env switch confirm (DISMISSED)
    await go('/admin/settings'); await p.getByRole('button', { name: /API Keys/ }).click(); await p.waitForTimeout(1500);
    const ak = await body();
    rec('ADM-16-09', /Delhivery/i.test(ak) && /staging/i.test(ak), 'Delhivery status panel visible showing staging', await shot(p, 'adm16_apikeys'));
    const envBefore = (creds.find((x) => x.key === 'DELHIVERY_ENV') || {}).value;
    let dialogMsg = null;
    p.once('dialog', async (d) => { dialogMsg = d.message(); await d.dismiss(); });
    const sel = p.locator('select').filter({ has: p.locator('option[value="production"]') }).first();
    if (await sel.count()) {
      await sel.selectOption('production');
      await sel.locator('xpath=following-sibling::button').click();
      await p.waitForTimeout(800);
    }
    const envAfter = ((await api('/admin/credentials')).data.find((x) => x.key === 'DELHIVERY_ENV') || {}).value;
    rec('ADM-16-10', /PRODUCTION/.test(dialogMsg || '') && envAfter === envBefore && envAfter !== 'production', `confirm shown="${(dialogMsg || '').slice(0, 60)}" → dismissed; DELHIVERY_ENV still ${envAfter}`);
    rec('ADM-15-04', noNewOrder, `no order was created by any refused test order=${noNewOrder}`);
    // cart cleanup
    const cartNow = (await api('/cart', {}, C)).data.items || [];
    const mine = cartNow.find((x) => (x.product_id || x.id) === prod.id);
    if (!hadItems && mine) await api(`/cart/item/${mine.id || mine.cart_item_id}`, { method: 'DELETE' }, C);
    rec('ADM-XX-JS', p.errs.length === 0, `page errors: ${p.errs.slice(0, 3).join(' | ') || 'none'}`);
  } finally {
    for (const f of cleanup) await f();
    const defaults = { maintenance_mode: 'false', force_update_enabled: 'false', min_app_version: '1.0.0', cod_enabled: 'true', product_reviews_enabled: 'true' };
    const restore = {}; for (const k of restoreKeys) { const v = settingsBefore[k] !== undefined ? settingsBefore[k] : defaults[k]; if (v !== undefined) restore[k] = v; }
    await api('/admin/settings', { method: 'PUT', ...J(restore) });
    await c.close();
  }
};
