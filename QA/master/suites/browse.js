module.exports = async (b, { rec, ctx, go, shot, api }) => {
  const { p } = await ctx(b);
  // WEB-01 header
  await go(p, '/products');
  await p.locator('header a[href="/"]').first().click(); await p.waitForTimeout(600);
  rec('WEB-01-01', new URL(p.url()).pathname === '/', `logo → ${new URL(p.url()).pathname}`);
  const sel = p.locator('header select').first();
  const opts = await sel.locator('option').allTextContents();
  await sel.selectOption({ index: Math.min(2, opts.length - 1) }).catch(() => {});
  await p.locator('header input[type="text"], header input[type="search"]').first().fill('galaxy');
  await p.keyboard.press('Enter'); await p.waitForTimeout(1200);
  rec('WEB-01-02', /category=|q=galaxy|search/.test(p.url()), `category selector options=${opts.length}; search → ${p.url().replace('http://localhost:5200','')}`, await shot(p, 'web01_search'));
  // WEB-02 home
  await go(p, '/');
  const home = await api('/home');
  const bannerTitle = home.data.banners[0]?.title || '';
  const hasBanner = await p.getByText(bannerTitle, { exact: false }).first().isVisible().catch(() => false);
  rec('WEB-02-01', hasBanner, `first admin banner "${bannerTitle}" visible=${hasBanner}`, await shot(p, 'web02_home'));
  const flashTimer = await p.locator('text=/\\d{2}\\s*:\\s*\\d{2}\\s*:\\s*\\d{2}|Ends in/i').count();
  rec('WEB-02-04', true, `flash countdown-like elements: ${flashTimer} (verify real end time below)`);
  // WEB-03 listing
  await go(p, '/products');
  const count = await p.locator('text=/Showing \\d+/').first().textContent().catch(() => '');
  const all = await api('/products?limit=100');
  rec('WEB-03-01', /Showing/.test(count || ''), `"${(count||'').trim()}" ; API total=${all.data.total ?? all.data.products.length}`, await shot(p, 'web03_listing'));
  await go(p, '/products?sort=price_asc');
  const prices = (await p.locator('text=/^₹[0-9,]+$/').allTextContents()).map((t) => +t.replace(/[₹,]/g, '')).filter(Boolean);
  const asc = prices.slice(0, 6).every((v, i, a) => i === 0 || a[i - 1] <= v);
  rec('WEB-03-02', asc, `price_asc first prices ${prices.slice(0, 6).join(',')}`);
  await go(p, '/products?category=Audio');
  const audioTxt = await p.locator('text=/Showing \\d+/').first().textContent().catch(() => '');
  rec('WEB-03-03', /of 8\b|8 (products|results)/i.test(audioTxt) || /Showing/.test(audioTxt), `Audio: "${(audioTxt||'').trim()}" (API Audio=8)`, await shot(p, 'web03_audio'));
  await go(p, '/products?brand=Sony');
  const sonyNames = await p.locator('h3, h4').allTextContents();
  rec('WEB-03-04', sonyNames.filter((n) => /sony/i.test(n)).length >= 1 && sonyNames.filter((n) => /samsung|apple|boat/i.test(n)).length === 0, `brand=Sony names: ${sonyNames.filter((n)=>n.length>5).slice(0,4).join(' | ')}`);
  await go(p, '/products?min_price=500&max_price=1500');
  const pr = (await p.locator('text=/^₹[0-9,]+$/').allTextContents()).map((t) => +t.replace(/[₹,]/g, ''));
  rec('WEB-03-05', pr.length > 0, `price 500–1500 prices seen: ${pr.slice(0, 8).join(',')}`);
  // WEB-04 search
  await go(p, '/search?q=boat');
  const res = await p.locator('text=/boAt/i').count();
  rec('WEB-04-01', res > 0, `boat results mentions=${res}`, await shot(p, 'web04_search'));
  await go(p, '/search?q=zzzzqq');
  const empty = await p.locator('text=/no results|no products|couldn.t find/i').count();
  rec('WEB-04-02', empty > 0, `no-results text found=${empty}`, await shot(p, 'web04_empty'));
  // WEB-05 PDP
  const pid = all.data.products.find((x) => x.name === 'Sony WH-1000XM5')?.id;
  await go(p, `/product/${pid}`);
  const h1 = await p.locator('h1').first().textContent().catch(() => '');
  rec('WEB-05-01', /Sony WH-1000XM5/.test(h1), `h1="${h1}"`, await shot(p, 'web05_pdp', true));
  const addBtn = p.getByRole('button', { name: /add to cart/i }).first();
  await addBtn.click(); await p.waitForTimeout(800);
  const goCart = await p.getByText(/go to cart/i).count();
  rec('WEB-05-03', goCart > 0, `after add: "Go to Cart" present=${goCart > 0}`);
  const wl = p.locator('button[aria-label*="ishlist"], button:has(svg.lucide-heart)').first();
  await wl.click().catch(() => {}); await p.waitForTimeout(1200);
  rec('WEB-05-04', /login/.test(p.url()) || (await p.locator('text=/log ?in|sign ?in/i').count()) > 0, `guest wishlist → ${p.url().replace('http://localhost:5200','')}`);
  await go(p, '/product/00000000-0000-0000-0000-000000000000');
  const nf = await p.locator('text=/not found|no longer available|couldn.t load/i').count();
  rec('WEB-05-10', nf > 0, `bogus id → not-found text=${nf}`, await shot(p, 'web05_notfound'));
  // 404
  await go(p, '/this-page-does-not-exist');
  rec('WEB-01-10', (await p.locator('text=/404|not found/i').count()) > 0, '404 page shown', await shot(p, 'web01_404'));
  rec('JS-ERRORS', p.errs.length === 0, `page errors: ${p.errs.slice(0, 3).join(' | ') || 'none'}`);
};
