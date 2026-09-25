module.exports = async (b, { rec, ctx, go, shot, api }) => {
  const prods = (await api('/products?limit=100')).data.products;
  const boat = prods.find((x) => x.name === 'boAt Airdopes 141 TWS');
  const rock = prods.find((x) => x.name === 'boAt Rockerz 550 Headphones');
  const item = (p, qty) => ({ id: p.id, name: p.name, img: '', price: +p.price, oldPrice: +(p.old_price || p.price), brand: 'boAt', category: 'Audio', qty });
  const money = (t) => +String(t).replace(/[^0-9.]/g, '');
  const rowVal = async (p, label) => { const row = p.locator(`div:has(> span:text-is("${label}"))`).last(); return (await row.locator('span').last().textContent().catch(() => '')).trim(); };

  // Cart below free-shipping threshold: 1 × ₹999? (999 ≥ 499 → free). Use nothing below 499 exists → check free + GST
  let { c, p } = await ctx(b, { auth: true, cart: [item(boat, 1)] });
  await go(p, '/cart');
  const cartTotal = (await p.locator('text=Total Amount').locator('xpath=following-sibling::span').first().textContent()).trim();
  const gstTxt = await p.locator('text=/GST \\(18%\\)/').locator('xpath=following-sibling::span').first().textContent().catch(() => '');
  rec('WEB-08-04', money(cartTotal) === 999 + 179.82 || Math.abs(money(cartTotal) - 1178.82) < 0.02, `cart: delivery Free (999 ≥ 499), GST ${gstTxt}, total ${cartTotal} (server would charge 1178.82)`, await shot(p, 'web08_cart'));
  // Checkout totals vs server
  await go(p, '/checkout'); await p.waitForTimeout(2500);
  const coTotal = await p.locator('text=Total Amount').locator('xpath=following-sibling::span').first().textContent();
  const express = await p.locator('text=/Express/').count();
  rec('WEB-09-04', express === 0, `Express option shown=${express > 0}`, await shot(p, 'web09_checkout', true));
  rec('WEB-09-06', Math.abs(money(coTotal) - 1178.82) < 0.6, `checkout total ${coTotal.trim()} vs server formula 1178.82`);
  // with coupon TEST20 (20% of 999 = 199.8) → tax on 799.2 = 143.86 → total 943.06
  // Own throwaway coupon (per-user coupons are consumed by earlier runs).
  const CODE = `QA20${Date.now().toString().slice(-5)}`;
  const adm = (path, o = {}) => fetch('http://localhost:5000/api' + path, { ...o, headers: { 'Content-Type': 'application/json', Authorization: `Bearer ${process.env.ADMIN_TOKEN}` } }).then((r) => r.json());
  const cc = await adm('/admin/coupons', { method: 'POST', body: JSON.stringify({ code: CODE, type: 'Percentage', value: 20, min_order: 500 }) });
  await p.locator('input[placeholder="Enter coupon code"]').fill(CODE);
  await p.getByRole('button', { name: /^apply$/i }).click(); await p.waitForTimeout(1500);
  const coTotal2 = await p.locator('text=Total Amount').locator('xpath=following-sibling::span').first().textContent();
  rec('WEB-09-05', Math.abs(money(coTotal2) - 943.06) < 0.6, `with ${CODE} (20%): ${coTotal2.trim()} (server formula 943.06)`, await shot(p, 'web09_coupon', true));
  // place COD order and compare with server order
  const before = (await api('/orders?limit=1')).data; const lastBefore = (before.orders || before)[0]?.order_number;
  await p.getByText(/pay on delivery|cash on delivery/i).first().click().catch(() => {});
  await p.getByRole('button', { name: /place order/i }).first().click(); await p.waitForTimeout(5000);
  const after = (await api('/orders?limit=1')).data; const o = (after.orders || after)[0];
  rec('WEB-09-07', o && o.order_number !== lastBefore && /order-success/.test(p.url()), `→ ${p.url().replace('http://localhost:5200','')} ; order ${o?.order_number} total ${o?.total} method ${o?.payment_method}`, await shot(p, 'web10_success', true));
  rec('WEB-09-06b', o && Math.abs(+o.total - money(coTotal2)) < 0.6, `server charged ${o?.total} vs shown ${coTotal2.trim()}`);
  const successTxt = await p.locator('body').innerText();
  rec('WEB-10-01', /CF\d+/.test(successTxt) && !/payment confirmed/i.test(successTxt), `success shows order id; mentions 'Payment Confirmed' for COD=${/payment confirmed/i.test(successTxt)}`);
  await c.close();
  if (cc.data?.id) await adm(`/admin/coupons/${cc.data.id}`, { method: 'DELETE' });
};
