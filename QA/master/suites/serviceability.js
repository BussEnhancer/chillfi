module.exports = async (b, { rec, ctx, go, shot, api }) => {
  const prods = (await api('/products?limit=100')).data.products;
  const boat = prods.find((x) => x.name === 'boAt Airdopes 141 TWS');
  // Self-contained: create the unserviceable test address, remove it at the end.
  const tmp = await api('/addresses', { method: 'POST', body: JSON.stringify({ name: 'QA Unserviceable', phone: '9876500001', line1: 'QA Street 1', city: 'Nowhere', state: 'Delhi', pincode: '999999', type: 'Home' }) });
  const tmpId = tmp.data?.address?.id || tmp.data?.id;
  const { p } = await ctx(b, { auth: true, cart: [{ id: boat.id, name: boat.name, img: '', price: +boat.price, oldPrice: +boat.old_price, brand: 'boAt', category: 'Audio', qty: 1 }] });
  await go(p, '/checkout'); await p.waitForTimeout(2000);
  await p.locator('button:has-text("999999")').first().click(); await p.waitForTimeout(2500);
  const t = await p.locator('body').innerText();
  const btn = p.getByRole('button', { name: /can't deliver|place order/i }).last();
  rec('WEB-09-03a', /can't deliver to pincode 999999/i.test(t) && await btn.isDisabled(), `999999: message=${/can't deliver/i.test(t)} button disabled=${await btn.isDisabled()}`, await shot(p, 'web09_unserviceable', true));
  await p.locator('button:has-text("110001")').first().click(); await p.waitForTimeout(3000);
  const btn2 = p.getByRole('button', { name: /place order/i }).last();
  rec('WEB-09-03b', !(await btn2.isDisabled()), `110001: place order enabled=${!(await btn2.isDisabled())}`);
  const r = await api('/orders', { method: 'POST', body: JSON.stringify({ address_id: tmpId, payment_method: 'COD' }) });
  rec('WEB-09-03c', r.success === false && /can't deliver/i.test(r.message), `API order to 999999 → ${r.message}`);
  if (tmpId) await api(`/addresses/${tmpId}`, { method: 'DELETE' });
};
