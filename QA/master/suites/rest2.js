module.exports = async (b, { rec, ctx, go, shot, api }) => {
  const body = async (p) => p.locator('body').innerText();
  const prods = (await api('/products?limit=100')).data.products;
  const boat = prods.find((x) => x.name === 'boAt Airdopes 141 TWS');
  const sony = prods.find((x) => x.name === 'Sony WH-1000XM5');
  const cartItem = { id: boat.id, name: boat.name, img: '', price: +boat.price, oldPrice: +boat.old_price, brand: 'boAt', category: 'Audio', qty: 1 };
  // touch: product card actions + gallery
  { const { c, p } = await ctx(b, { w: 390, h: 844 });
    await go(p, '/products?category=Audio');
    const addBtns = p.getByRole('button', { name: /add to cart/i });
    const vis = await addBtns.first().isVisible();
    await addBtns.first().click(); await p.waitForTimeout(800);
    const n = JSON.parse(await p.evaluate(() => localStorage.getItem('chillfi_cart') || '[]')).length;
    rec('WEB-02-10', vis && n === 1, `390px: Add to Cart visible=${vis}, cart items=${n}`, await shot(p, 'web02_touch_card'));
    rec('WEB-03-08', n === 1, 'card add → cart');
    await go(p, `/product/${sony.id}`);
    const imgs = await p.locator('img').count();
    rec('WEB-05-02', imgs > 0, `gallery images=${imgs} (seed has 1 image/product; arrows visible below lg)`, await shot(p, 'web05_gallery_mobile'));
    await go(p, '/account'); // guest → login redirect expected
    rec('WEB-11-04a', /login/.test(p.url()), `guest /account → ${p.url().replace('http://localhost:5200','')}`);
    await c.close(); }
  { const { c, p } = await ctx(b, { auth: true, w: 390, h: 844, cart: [cartItem] });
    await go(p, '/account');
    const nav = await p.locator('nav[aria-label="Account menu"] a[href]').evaluateAll((els) => els.map((e) => e.getAttribute('href')));
    rec('WEB-11-04', nav.length >= 6, `mobile account nav links: ${nav.join(' ')}`, await shot(p, 'web11_account_mobile'));
    // orders mobile: pagination fits + card + view details
    await go(p, '/account/orders');
    const sw = await p.evaluate(() => document.documentElement.scrollWidth - innerWidth);
    rec('WEB-12-05', sw <= 0, `orders page 390px overflow=${sw}`, await shot(p, 'web12_orders_mobile', true));
    await c.close(); }
  { const { c, p } = await ctx(b, { auth: true, cart: [cartItem] });
    await go(p, '/account/orders');
    const card = await body(p);
    const first = ((await api('/orders?limit=1')).data.orders)[0];
    rec('WEB-12-02', card.includes(first.order_number) && /qty|item/i.test(card), `card shows ${first.order_number}, status + qty`);
    await p.getByText(/view details/i).first().click(); await p.waitForTimeout(1500);
    rec('WEB-12-03', /\/track/.test(p.url()), `View Details → ${p.url().replace('http://localhost:5200','')}`);
    const del = ((await api('/orders?search=CF4266319808')).data.orders)[0];
    await go(p, `/account/orders/${del.id}/track`);
    rec('WEB-13-02', /Delivered/.test(await body(p)), 'progress tracker shows Delivered stage', await shot(p, 'web13_progress'));
    // write review (PDP) with validation
    await go(p, `/product/${sony.id}`);
    await p.getByRole('button', { name: /^Reviews/ }).first().click(); await p.waitForTimeout(400);
    await p.getByRole('button', { name: /write a review/i }).first().click().catch(() => {}); await p.waitForTimeout(400);
    await p.getByRole('button', { name: /submit/i }).first().click().catch(() => {}); await p.waitForTimeout(600);
    const rv = await body(p);
    const submitDisabled = await p.getByRole('button', { name: /submit review/i }).first().isDisabled().catch(() => false);
    rec('WEB-05-07a', submitDisabled || /select a rating|rating is required|please (select|choose)/i.test(rv), `empty review → ${(rv.match(/[^\n]*(rating)[^\n]*/i) || ['none'])[0].slice(0, 60)}`, await shot(p, 'web05_review_validation'));
    await p.locator('button:has(svg.lucide-star)').nth(4).click().catch(() => {});
    await p.locator('textarea').first().fill('Web QA review — great ANC').catch(() => {});
    await p.getByRole('button', { name: /submit/i }).first().click().catch(() => {}); await p.waitForTimeout(1500);
    const pr = (await api(`/products/${sony.id}`)).data.product;
    rec('WEB-05-07', +pr.review_count >= 1, `after submit: product rating ${pr.rating} (${pr.review_count})`, await shot(p, 'web05_review_done'));
    const myr = await api('/profile/reviews');
    await go(p, '/account/reviews');
    rec('WEB-14-06', /Sony WH-1000XM5/.test(await body(p)), 'my reviews lists the new review', await shot(p, 'web14_reviews'));
    // checkout: address select + add validation + failure keeps cart
    await go(p, '/checkout'); await p.waitForTimeout(1500);
    const addrBtns = await p.locator('button:has-text("DLV-TEST")').count();
    rec('WEB-09-01', addrBtns >= 1, `saved addresses selectable (${addrBtns})`);
    await p.getByRole('button', { name: /add new|add address/i }).first().click().catch(() => {}); await p.waitForTimeout(500);
    await p.getByRole('button', { name: /save/i }).first().click().catch(() => {}); await p.waitForTimeout(800);
    rec('WEB-09-02', /required|valid|enter|please fill in/i.test(await body(p)), 'empty address → field errors', await shot(p, 'web09_addr_validation', true));
    await go(p, '/checkout'); await p.waitForTimeout(2500);
    await p.route('**/api/orders', (r) => r.request().method() === 'POST' ? r.fulfill({ status: 500, contentType: 'application/json', body: '{"success":false,"message":"error: relation orders deadlock"}' }) : r.continue());
    await p.getByRole('button', { name: /place order/i }).last().click(); await p.waitForTimeout(2500);
    const dlg = await p.getByRole('alertdialog').innerText().catch(() => '');
    const cartLeft = JSON.parse(await p.evaluate(() => localStorage.getItem('chillfi_cart') || '[]')).length;
    rec('WEB-17-07', /couldn.t place your order/i.test(dlg) && !/deadlock|relation/i.test(dlg), `dialog: ${dlg.replace(/\s+/g, ' ').slice(0, 90)}`, await shot(p, 'web17_place_fail'));
    rec('WEB-09-09', cartLeft === 1, `cart kept after failure: ${cartLeft} item`);
    await p.unroute('**/api/orders');
    // success page track link / failed page
    await go(p, `/order-success?order_number=${first.order_number}&total=${first.total}`);
    await p.getByRole('link', { name: /track my order/i }).click().catch(() => {}); await p.waitForTimeout(1200);
    rec('WEB-10-02', /\/account\/orders/.test(p.url()), `Track My Order → ${p.url().replace('http://localhost:5200','')}`);
    await go(p, '/order-failed?reason=Payment%20declined%20by%20bank');
    const fb = await body(p);
    rec('WEB-10-03', /declined|failed|reason/i.test(fb), `failed page reason shown`, await shot(p, 'web10_failed', true));
    await p.getByRole('link', { name: /try again|retry/i }).first().click().catch(() => p.getByRole('button', { name: /try again|retry/i }).first().click().catch(() => {})); await p.waitForTimeout(1200);
    rec('WEB-10-04', /checkout|cart/.test(p.url()) && JSON.parse(await p.evaluate(() => localStorage.getItem('chillfi_cart') || '[]')).length > 0, `Try Again → ${p.url().replace('http://localhost:5200','')}, cart kept`);
    // tracking cancel failure dialog
    const proc = ((await api('/orders?status=Processing&limit=1')).data.orders)[0];
    if (proc) {
      await go(p, `/account/orders/${proc.id}/track`);
      await p.route(`**/api/orders/${proc.id}/cancel`, (r) => r.abort('internetdisconnected'));
      await p.getByRole('button', { name: /cancel order/i }).first().click(); await p.waitForTimeout(500);
      await p.getByRole('button', { name: /(yes|confirm).*cancel|cancel order/i }).last().click(); await p.waitForTimeout(1500);
      const d2 = await p.getByRole('alertdialog').innerText().catch(() => '');
      rec('WEB-17-08', /couldn.t cancel|no internet/i.test(d2), `cancel failure dialog: ${d2.replace(/\s+/g, ' ').slice(0, 80)}`, await shot(p, 'web17_cancel_fail'));
      const still = (await api(`/orders/${proc.id}`)).data.order.status;
      rec('WEB-17-08b', still === 'Processing', `order still ${still}`);
    }
    rec('JS-ERRORS', p.errs.length === 0, `page errors: ${p.errs.slice(0, 3).join(' | ') || 'none'}`);
    await c.close(); }
};
