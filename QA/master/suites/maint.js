module.exports = async (b, { rec, ctx, go, shot, api }) => {
  const set = (on) => fetch('http://localhost:5000/api/admin/settings', { method: 'PUT', headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${process.env.ADMIN_TOKEN}` }, body: JSON.stringify({ maintenance_mode: on }) });
  await set(true);
  try {
  const { p } = await ctx(b);
  for (const pg of ['/', '/products', '/categories', '/offers']) { await go(p, pg); if (!/maintenance|be right back/i.test(await p.locator('body').innerText())) { rec('WEB-01-09', false, `${pg} not gated`); return; } }
  await shot(p, 'web01_maintenance');
  await go(p, '/admin'); const t = await p.locator('body').innerText();
  rec('WEB-01-09', !/under maintenance|be right back/i.test(t), `customer pages gated; /admin → ${p.url().replace('http://localhost:5200','')} not gated=${!/under maintenance|be right back/i.test(t)}`, await shot(p, 'web01_admin_during_maint'));
  } finally { await set(false); }
};
