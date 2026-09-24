module.exports = async (b, { rec, ctx, go, shot, api, fs }) => {
  const TOKA = process.env.ADMIN_TOKEN;
  const c = await b.newContext({ viewport: { width: 1440, height: 900 } });
  await c.addInitScript((t) => { localStorage.setItem('access_token', t); localStorage.setItem('refresh_token', 'none'); }, TOKA);
  const p = await c.newPage(); const errs = []; p.on('pageerror', (e) => errs.push(e.message));
  const failedReq = []; p.on('response', (r) => { if (r.url().includes('/api/') && r.status() >= 400) failedReq.push(`${r.status()} ${r.request().method()} ${r.url().replace(/.*\/api/, '')}`); });
  const pages = ['dashboard', 'products', 'orders', 'refunds', 'users', 'categories', 'brands', 'reviews', 'messages', 'notifications', 'analytics', 'banners', 'promo-banners', 'testimonials', 'coupons', 'shipping-rules', 'settings'];
  const report = {};
  for (const pg of pages) {
    errs.length = 0; failedReq.length = 0;
    await p.goto(`http://localhost:5200/admin/${pg}`, { waitUntil: 'networkidle' }); await p.waitForTimeout(800);
    const dead = await p.evaluate(() => [...document.querySelectorAll('button')].filter((b) => {
      const k = Object.keys(b).find((x) => x.startsWith('__reactProps'));
      const props = k ? b[k] : {};
      return !props.onClick && b.type !== 'submit' && !b.disabled && b.offsetParent !== null;
    }).map((b) => (b.innerText || b.getAttribute('title') || b.getAttribute('aria-label') || '(icon)').trim().slice(0, 30)));
    const text = await p.locator('main, body').first().innerText();
    report[pg] = { url: p.url().replace('http://localhost:5200', ''), jsErrors: [...errs], apiFailures: [...new Set(failedReq)], deadButtons: [...new Set(dead)].slice(0, 15), sample: text.replace(/\s+/g, ' ').slice(0, 300) };
    await shot(p, `admin_${pg}`, true);
    rec(`sweep:${pg}`, errs.length === 0 && failedReq.length === 0 && dead.length === 0, `js=${errs.length} api=${[...new Set(failedReq)].join(',') || 0} dead=[${[...new Set(dead)].slice(0, 8).join(' | ')}]`);
  }
  fs.writeFileSync('results/web/admin_sweep.json', JSON.stringify(report, null, 1));
  await c.close();
};
