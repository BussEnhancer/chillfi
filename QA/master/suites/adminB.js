module.exports = async (b, { rec, shot }) => {
  const A = process.env.ADMIN_TOKEN, BASE = 'http://localhost:5200';
  const api = async (path, opts = {}, tok = A) => (await fetch('http://localhost:5000/api' + path, { ...opts, headers: { 'Content-Type': 'application/json', ...(tok ? { Authorization: `Bearer ${tok}` } : {}), ...(opts.headers || {}) } })).json();
  const c = await b.newContext({ viewport: { width: 1440, height: 900 } });
  await c.addInitScript((t) => { localStorage.setItem('access_token', t); localStorage.setItem('refresh_token', 'none'); }, A);
  const p = await c.newPage(); p.errs = []; p.on('pageerror', (e) => p.errs.push(e.message));
  const go = async (path) => { await p.goto(BASE + path, { waitUntil: 'networkidle' }); await p.waitForTimeout(700); };
  const NAME = 'QA UI Speaker ' + Date.now().toString().slice(-5);
  await go('/admin/products');
  await p.getByRole('button', { name: /add product/i }).first().click(); await p.waitForTimeout(500);
  const modal = p.locator('div.fixed').last();
  await modal.locator('input[placeholder^="e.g. Samsung Galaxy"]').fill(NAME);
  await modal.locator('input[placeholder="e.g. Samsung"]').fill('QA Brand');
  await modal.locator('select').first().selectOption('Audio');
  const nums = modal.locator('input[type="number"]');
  await nums.nth(0).fill('1499'); await nums.nth(1).fill('1999'); await nums.nth(2).fill('12');
  await modal.getByRole('button', { name: /save|add|create/i }).last().click(); await p.waitForTimeout(2500);
  const all = (await api('/admin/products?limit=1000&status=all')).data.products;
  const made = all.find((x) => x.name === NAME);
  rec('ADM-03-03', !!made && made.category_name === 'Audio' && made.brand_name === 'QA Brand' && !p.errs.length, `created=${!!made} category=${made?.category_name} brand=${made?.brand_name} page errors=${p.errs.length}`, await shot(p, 'adm03_added'));
  if (!made) { await c.close(); return; }
  const pub = async () => (await api(`/products/${made.id}`, {}, null)).data?.product;
  rec('ADM-03-11a', (await pub())?.name === NAME, 'new product visible on storefront API');
  // edit price/name
  await p.locator("main input[placeholder=\"Search products...\"], input.w-60[placeholder=\"Search products...\"]").last().fill(NAME); await p.waitForTimeout(500);
  await p.locator('button[title="Edit"]').first().click(); await p.waitForTimeout(500);
  const m2 = p.locator('div.fixed').last();
  await m2.locator('input[placeholder^="e.g. Samsung Galaxy"]').fill(NAME + ' v2');
  await m2.locator('input[type="number"]').nth(0).fill('1399');
  await m2.getByRole('button', { name: /save|update/i }).last().click(); await p.waitForTimeout(2500);
  const e2 = await pub();
  rec('ADM-03-05', e2?.name === NAME + ' v2' && +e2.price === 1399 && e2.brand_name === 'QA Brand', `edited → ${e2?.name} ₹${e2?.price} brand ${e2?.brand_name}`);
  rec('ADM-03-11', +e2.price === 1399, 'price/name change visible to storefront (app + web read same API)');
  // inline stock + status
  await p.locator("main input[placeholder=\"Search products...\"], input.w-60[placeholder=\"Search products...\"]").last().fill(NAME); await p.waitForTimeout(600);
  const row = p.locator('tr', { hasText: NAME }).first();
  await row.locator('input[type="number"]').fill('3'); await row.locator('input[type="number"]').press('Tab'); await p.waitForTimeout(1500);
  rec('ADM-03-06', +(await pub()).stock === 3, `inline stock → ${(await pub()).stock}`);
  await row.locator('select').selectOption('Out of Stock'); await p.waitForTimeout(1500);
  const oos = await pub(); const cartTry = await api('/cart/add', { method: 'POST', body: JSON.stringify({ product_id: made.id, quantity: 1 }) }, process.env.CUSTOMER_TOKEN);
  rec('ADM-03-12', oos.status === 'Out of Stock' && cartTry.success === false, `status Out of Stock; customer add-to-cart → ${cartTry.message}`);
  await row.locator('select').selectOption('Low Stock'); await p.waitForTimeout(1500);
  const lowIn = (await api('/products/trending?limit=100', {}, null)).data.products.some((x) => x.id === made.id) || (await api(`/products?limit=100`, {}, null)).data.products.some((x) => x.id === made.id);
  rec('ADM-03-12b', lowIn, 'Low Stock still listed/sellable');
  await row.locator('select').selectOption('Inactive'); await p.waitForTimeout(1500);
  const hidden = !(await api('/products?limit=500', {}, null)).data.products.some((x) => x.id === made.id);
  const stillAdmin = (await api('/admin/products?limit=1000&status=all')).data.products.some((x) => x.id === made.id);
  await row.locator('select').selectOption('Active'); await p.waitForTimeout(1500);
  rec('ADM-03-07', hidden && stillAdmin && (await pub()).status === 'Active', `Inactive: hidden from store=${hidden}, still in admin=${stillAdmin}; re-activated=${(await pub()).status}`, await shot(p, 'adm03_inline'));
  // featured toggle via edit
  await p.locator('button[title="Edit"]').first().click(); await p.waitForTimeout(500);
  await p.locator('div.fixed').last().locator('input[type="checkbox"]').first().check(); await p.locator('div.fixed').last().getByRole('button', { name: /save|update/i }).last().click(); await p.waitForTimeout(2000);
  rec('ADM-03-08', (await pub()).is_featured === true, `featured=${(await pub()).is_featured}`);
  // deactivate (delete button)
  await p.locator('button[title="Deactivate"]').first().click(); await p.waitForTimeout(400);
  const dlg = await p.locator('div.fixed', { hasText: 'Deactivate Product?' }).last().innerText();
  await p.getByRole('button', { name: /^Deactivate$/ }).last().click(); await p.waitForTimeout(1500);
  rec('ADM-03-10', /hidden from the store/i.test(dlg) && (await pub())?.status === 'Inactive', `confirm text honest=${/hidden from the store/i.test(dlg)}; status ${(await pub())?.status}`, await shot(p, 'adm03_deactivated'));
  rec('JS-ERRORS', p.errs.length === 0, `page errors: ${p.errs.slice(0, 3).join(' | ') || 'none'}`);
  await c.close();
};
