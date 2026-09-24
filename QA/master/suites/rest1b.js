module.exports = async (b, { rec, ctx, go, shot, api }) => {
  const body = async (p) => p.locator('body').innerText();
  { const { c, p } = await ctx(b);
    await go(p, '/'); await p.locator('a[href*="/products?category="]').first().click(); await p.waitForTimeout(2000);
    rec('WEB-02-03', /category=/.test(p.url()) && /showing/i.test(await body(p)), `category tile → ${(await body(p)).match(/showing [^\n]*/i)?.[0]}`);
    await go(p, '/products'); await p.getByRole('button', { name: 'Next page' }).click(); await p.waitForTimeout(1500);
    rec('WEB-03-07', /showing 21–22 of 22/i.test(await body(p)), `next page → ${(await body(p)).match(/showing [^\n]*/i)?.[0]}`, await shot(p, 'web03_page2'));
    await p.route('**/api/products**', (r) => r.abort('internetdisconnected'));
    await go(p, '/products?category=Audio'); const eb = await body(p);
    rec('WEB-03-10', /Can't load products/.test(eb) && /Try again/.test(eb), `offline listing: ${(eb.match(/Can't load[^\n]*/) || ['-'])[0]}`, await shot(p, 'web03_error'));
    await p.unroute('**/api/products**'); await p.getByRole('button', { name: 'Try again' }).click(); await p.waitForTimeout(1500);
    rec('WEB-03-10b', /showing/i.test(await body(p)), 'retry after reconnect loads products');
    await c.close(); }
  { const { c, p } = await ctx(b, { auth: true });
    const prods = (await api('/products?limit=100')).data.products; const sony = prods.find((x) => x.name === 'Sony WH-1000XM5');
    await go(p, '/'); await p.waitForTimeout(1500);
    const n0 = ((await api('/wishlist')).data).length; const b0 = (await p.locator('header a[href*="wishlist"]').first().innerText()).replace(/\D/g, '');
    rec('WEB-05-05a', String(n0) === b0 || (n0 === 0 && b0 === ''), `on load: server ${n0}, header badge '${b0}' (synced from server)`);
    await go(p, `/product/${sony.id}`); await p.getByRole('button', { name: /wishlist/i }).first().click(); await p.waitForTimeout(2000);
    const n1 = ((await api('/wishlist')).data).length; const b1 = (await p.locator('header a[href*="wishlist"]').first().innerText()).replace(/\D/g, '');
    rec('WEB-05-05', String(n1) === b1 || (n1 === 0 && b1 === ''), `after PDP toggle: server ${n1}, header badge '${b1}'`, await shot(p, 'web05_wishlist_badge'));
    await c.close(); }
};
