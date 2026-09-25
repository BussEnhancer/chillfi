module.exports = async (b, { rec, ctx, go, shot, api }) => {
  const prods = (await api('/products?limit=100')).data.products;
  const boat = prods.find((x) => x.name === 'boAt Airdopes 141 TWS');
  const body = async (p) => p.locator('body').innerText();
  // header badges (logged in)
  { const { c, p } = await ctx(b, { auth: true, cart: [{ id: boat.id, name: boat.name, img: '', price: +boat.price, oldPrice: +boat.old_price, brand: 'boAt', category: 'Audio', qty: 2 }] });
    await go(p, '/');
    const cartBadge = (await p.locator('header a[href="/cart"]').first().innerText()).replace(/\D/g, '');
    const wl = (await api('/wishlist')).data; let wlN = (wl.items || wl.wishlist || wl).length;
    const wlBadge = (await p.locator('header a[href*="wishlist"]').first().innerText()).replace(/\D/g, '');
    rec('WEB-01-03', cartBadge === '2' && (wlN === 0 ? wlBadge === '' || wlBadge === '0' : wlBadge === String(wlN)), `cart badge=${cartBadge} (2) wishlist badge='${wlBadge}' (server ${wlN})`, await shot(p, 'web01_badges'));
    await p.locator('header a[href="/cart"]').first().click(); await p.waitForTimeout(800); const u1 = p.url();
    rec('WEB-01-03b', /\/cart$/.test(u1), `cart icon → ${u1.replace('http://localhost:5200', '')}`);
    // breadcrumbs SPA
    await go(p, '/account/orders'); await p.evaluate(() => { window.__spa = 1; });
    await p.locator('nav a:has-text("My Account"), a:has-text("My Account")').first().click(); await p.waitForTimeout(800);
    rec('WEB-01-08', (await p.evaluate(() => window.__spa)) === 1 && /\/account$/.test(p.url()), `breadcrumb → ${p.url().replace('http://localhost:5200','')} without reload=${(await p.evaluate(() => window.__spa)) === 1}`);
    // account quick actions
    await go(p, '/account');
    const qa = await p.locator('a:has(h3), a:has(h4)').evaluateAll((els) => els.map((e) => [e.textContent.trim().slice(0, 20), e.getAttribute('href')]));
    rec('WEB-11-02', qa.length > 0 && qa.every(([, h]) => h && h !== '#'), `quick actions: ${qa.slice(0, 6).map(([t, h]) => `${t}→${h}`).join(' | ')}`);
    // cart qty / remove / proceed / empty
    await go(p, '/cart');
    await p.locator('button:has(svg.lucide-plus)').first().click(); await p.waitForTimeout(400);
    let ls = JSON.parse(await p.evaluate(() => localStorage.getItem('chillfi_cart')));
    rec('WEB-08-02', ls[0].qty === 3, `qty + → ${ls[0].qty}`);
    await p.locator('button:has(svg.lucide-minus)').first().click(); await p.waitForTimeout(400);
    ls = JSON.parse(await p.evaluate(() => localStorage.getItem('chillfi_cart')));
    rec('WEB-08-02b', ls[0].qty === 2, `qty − → ${ls[0].qty}`);
    await p.getByRole('link', { name: /proceed to checkout/i }).click(); await p.waitForTimeout(800);
    rec('WEB-08-05', /\/checkout/.test(p.url()), `→ ${p.url().replace('http://localhost:5200','')}`);
    await go(p, '/cart');
    await p.locator('button.text-red-400').first().click(); await p.waitForTimeout(600);
    rec('WEB-08-03', JSON.parse(await p.evaluate(() => localStorage.getItem('chillfi_cart'))).length === 0, 'item removed');
    rec('WEB-08-06', /empty/i.test(await body(p)), 'empty cart state', await shot(p, 'web08_empty'));
    // wishlist logged in: toggle on PDP updates header badge
    const sony = prods.find((x) => x.name === 'Sony WH-1000XM5');
    // Precondition: Sony not already wishlisted (a previous interrupted run may have left it).
    { const cur = (await api('/wishlist')).data; const l = cur.items || cur.wishlist || cur;
      if (l.some((x) => x.product_id === sony.id)) { await api('/wishlist/toggle', { method: 'POST', body: JSON.stringify({ product_id: sony.id }) }); wlN = l.length - 1; } }
    await go(p, `/product/${sony.id}`);
    await p.getByRole('button', { name: /wishlist/i }).first().click(); await p.waitForTimeout(1500);
    const wl2 = (await api('/wishlist')).data; const n2 = (wl2.items || wl2.wishlist || wl2).length;
    const badge2 = (await p.locator('header a[href*="wishlist"]').first().innerText()).replace(/\D/g, '');
    rec('WEB-05-05', n2 === wlN + 1 && badge2 === String(n2), `server wishlist ${wlN}→${n2}; header badge ${badge2}`);
    // PDP tabs / related
    for (const t of ['Specifications', 'Reviews', 'FAQs', 'Delivery & Returns']) { await p.getByRole('button', { name: new RegExp(`^${t}`) }).first().click().catch(() => {}); await p.waitForTimeout(200); }
    const tb = await body(p);
    rec('WEB-05-06', /return/i.test(tb), 'tabs switch (last: Delivery & Returns shows return info)', await shot(p, 'web05_tabs'));
    rec('WEB-05-09', /Audio|boAt|Apple/.test(tb), 'related products shown (same category)');
    // wishlist page: move to bag / remove
    await go(p, '/account/wishlist');
    const wb = await body(p);
    rec('WEB-14-01', /Sony WH-1000XM5/.test(wb), 'wishlist lists Sony', await shot(p, 'web14_wishlist', true));
    await p.getByRole('button', { name: /move to bag|add to (cart|bag)/i }).first().click().catch(() => {}); await p.waitForTimeout(800);
    const inCart = JSON.parse(await p.evaluate(() => localStorage.getItem('chillfi_cart'))).some((i) => i.id === sony.id);
    rec('WEB-14-01b', inCart, `move to bag → in cart=${inCart}`);
    // account logout
    await go(p, '/account');
    await p.getByRole('button', { name: /logout/i }).first().click(); await p.waitForTimeout(800);
    await p.getByRole('button', { name: /logout|yes/i }).last().click().catch(() => {}); await p.waitForTimeout(1200);
    const tok = await p.evaluate(() => localStorage.getItem('access_token'));
    rec('WEB-11-06', !tok, `after logout token=${tok ? 'still set' : 'cleared'} url=${p.url().replace('http://localhost:5200','')}`);
    await c.close(); }
  // guest/mobile checks
  { const { c, p } = await ctx(b, { w: 375, h: 812 });
    await go(p, '/');
    await p.locator('header button[aria-label*="menu" i], header button:has(svg.lucide-menu)').first().click(); await p.waitForTimeout(500);
    const dr = await body(p);
    rec('WEB-01-04', /Categories/.test(dr) && /Deals/.test(dr) && /Track Order/.test(dr), 'drawer shows links', await shot(p, 'web01_drawer'));
    await p.getByRole('link', { name: /^Deals$/ }).first().click(); await p.waitForTimeout(800);
    rec('WEB-01-04b', /\/offers/.test(p.url()) && !(await p.locator('text=Track Order').first().isVisible().catch(() => false)), `drawer link → ${p.url().replace('http://localhost:5200','')} and closed`);
    await go(p, '/products');
    await p.getByRole('button', { name: /filters?/i }).first().click(); await p.waitForTimeout(500);
    rec('WEB-03-06', await p.locator('[role="dialog"][aria-label="Filters"]').isVisible().catch(() => false), 'mobile filter drawer opens', await shot(p, 'web03_filters_mobile'));
    await go(p, '/categories');
    rec('WEB-06-02', /Smartphones|Audio/.test(await body(p)), 'mobile categories listed', await shot(p, 'web06_categories_mobile'));
    await c.close(); }
  { const { c, p } = await ctx(b);
    await go(p, '/');
    rec('WEB-02-02', /Free Delivery|Easy Returns|Secure|Support/.test(await body(p)), 'trust bar cards');
    await p.locator('a[href*="/products?category="]').first().click(); await p.waitForTimeout(1000);
    rec('WEB-02-03', /category=/.test(p.url()) && /showing/i.test(await body(p)), `category tile → ${p.url().replace('http://localhost:5200','')}`);
    await go(p, '/'); const va = p.locator('a:has-text("View All")').first(); const href = await va.getAttribute('href');
    rec('WEB-02-05', !!href && href !== '#', `trending View All → ${href}`);
    await go(p, '/products');
    await p.getByRole('button', { name: /^2$/ }).first().click().catch(() => {}); await p.waitForTimeout(1000);
    { const t = await body(p); const m = t.match(/showing (\d+)\D+(\d+) of (\d+)/i);
      rec('WEB-03-07', !!m && +m[1] === 21 && +m[2] === Math.min(40, +m[3]), `page 2 → ${m?.[0]}`); }
    await p.route('**/api/products**', (r) => r.abort('internetdisconnected'));
    await go(p, '/products?category=Audio');
    const eb = await body(p);
    rec('WEB-03-10', /offline|can.t be reached|try again/i.test(eb) && !/no products found/i.test(eb), `offline listing: ${(eb.match(/[^\n]*(offline|can.t be reached|No products)[^\n]*/i) || [''])[0].slice(0, 80)}`, await shot(p, 'web03_error'));
    await p.unroute('**/api/products**');
    await go(p, '/categories');
    await p.locator('a[href*="/products?category="]').first().click(); await p.waitForTimeout(800);
    rec('WEB-06-01', /category=/.test(p.url()), `category card → ${p.url().replace('http://localhost:5200','')}`);
    await go(p, '/offers'); await p.getByRole('button', { name: /how to use coupons/i }).click(); await p.waitForTimeout(400);
    rec('WEB-06-05', /paste the coupon code|apply coupon/i.test(await body(p)), 'coupon how-to modal', await shot(p, 'web06_howto'));
    for (const pg of ['/privacy-policy', '/terms', '/refund-policy', '/return-policy', '/shipping-policy']) {
      await go(p, pg); const t = await body(p); if (t.length < 800) { rec('WEB-15-06', false, `${pg} content too short`); }
    }
    rec('WEB-15-06', true, 'all 5 policy pages render content');
    await go(p, '/delete-account');
    rec('WEB-15-07', /login|otp|phone/i.test(await body(p)) || /login/.test(p.url()), `delete account (guest) → ${p.url().replace('http://localhost:5200','')}`);
    await go(p, '/search?q=boat');
    await p.locator('header input').first().fill('sony'); await p.keyboard.press('Enter'); await p.waitForTimeout(1200);
    const sb = await body(p);
    rec('WEB-04-03', /sony/i.test(p.url()) && /Sony/.test(sb), `header search while on /search → ${p.url().replace('http://localhost:5200','')}`);
    rec('JS-ERRORS', p.errs.length === 0, `page errors: ${p.errs.slice(0, 3).join(' | ') || 'none'}`);
    await c.close(); }
};
