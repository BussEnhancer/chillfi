module.exports = async (b, { rec, ctx, go, shot, api }) => {
  const prods = (await api('/products?limit=100')).data.products; const boat = prods.find((x) => x.name === 'boAt Airdopes 141 TWS');
  const { p } = await ctx(b, { auth: true, cart: [{ id: boat.id, name: boat.name, img: '', price: +boat.price, oldPrice: +boat.old_price, brand: 'boAt', category: 'Audio', qty: 1 }] });
  await go(p, '/checkout'); await p.waitForTimeout(1500);
  await p.getByRole('button', { name: /add new|add address/i }).first().click(); await p.waitForTimeout(400);
  await p.getByRole('button', { name: /save address/i }).click(); await p.waitForTimeout(500);
  const t1 = await p.locator('body').innerText();
  rec('WEB-09-02', /Please fill in name/.test(t1), 'empty → "Please fill in name, mobile…"', await shot(p, 'web09_addr_validation', true));
  await p.locator('input[placeholder*="ame" i]').last().fill('QA');
  const ph = p.locator('input[placeholder*="obile" i], input[placeholder*="hone" i]').last(); await ph.fill('12345');
  for (const [k, v] of [['Address Line 1', '1 St'], ['ity', 'Delhi'], ['tate', 'Delhi'], ['incode', '110001']]) await p.locator(`input[placeholder*="${k}" i]`).last().fill(v).catch(() => {});
  await p.getByRole('button', { name: /save address/i }).click(); await p.waitForTimeout(500);
  rec('WEB-09-02b', /valid 10-digit mobile/.test(await p.locator('body').innerText()), 'bad phone → message');
  const nav = await (async () => { const c2 = await b.newContext({ viewport: { width: 390, height: 844 } }); await c2.addInitScript((t) => { localStorage.setItem('access_token', t); localStorage.setItem('refresh_token', 'none'); }, process.env.CUSTOMER_TOKEN); const q = await c2.newPage(); await q.goto('http://localhost:5200/account', { waitUntil: 'networkidle' }); const n = await q.locator('nav[aria-label="Account menu"] a, nav[aria-label="Account menu"] button').allTextContents(); await c2.close(); return n; })();
  rec('WEB-11-04', nav.length >= 6, `mobile account menu: ${nav.map((s) => s.trim()).join(' | ')}`);
};
