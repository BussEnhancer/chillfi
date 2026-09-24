module.exports = async (b, { rec, ctx, go, shot, api }) => {
  const { p } = await ctx(b);
  for (const pg of ['/', '/products', '/cart']) { await go(p, pg); if (!/maintenance/i.test(await p.locator('body').innerText())) { rec('WEB-01-09', false, `${pg} not gated`); return; } }
  await shot(p, 'web01_maintenance');
  await go(p, '/admin'); const t = await p.locator('body').innerText();
  rec('WEB-01-09', !/under maintenance/i.test(t), `customer pages gated; /admin → ${p.url().replace('http://localhost:5200','')} not gated=${!/under maintenance/i.test(t)}`, await shot(p, 'web01_admin_during_maint'));
};
