module.exports = async (b, { rec, ctx, go, shot }) => {
  for (const w of [1440, 320]) {
    const { c, p } = await ctx(b, { w, h: w < 500 ? 700 : 900 });
    await go(p, '/login');
    const phone = p.locator('input[type="tel"], input[placeholder*="obile" i], input[placeholder*="hone" i]').first();
    await phone.fill('12345abc');
    const v = await phone.inputValue();
    await p.getByRole('button', { name: /send otp|get otp|continue/i }).first().click().catch(() => {}); await p.waitForTimeout(800);
    const t1 = await p.locator('body').innerText();
    rec(`WEB-07-02@${w}`, /valid|10-digit|10 digit/i.test(t1), `typed '12345abc' → field '${v}'; message=${(t1.match(/[^\n]*(valid|10-digit)[^\n]*/i) || [''])[0].slice(0, 70)}`, await shot(p, `web07_login_${w}`));
    const reg = p.getByRole('button', { name: /register|sign up/i }).first();
    if (await reg.count()) {
      await reg.click(); await p.waitForTimeout(500);
      const t2 = await p.locator('body').innerText();
      rec(`WEB-07-01@${w}`, /name/i.test(t2) && /email/i.test(t2), 'Register tab shows name + email', await shot(p, `web07_register_${w}`));
      const em = p.locator('input[type="email"], input[placeholder*="mail" i]').first();
      if (await em.count()) {
        await p.locator('input[placeholder*="ame" i]').first().fill('QA Web').catch(() => {});
        await em.fill('bad-email'); await phone.fill('9876543210');
        await p.getByRole('button', { name: /send otp|get otp|continue|register/i }).last().click().catch(() => {}); await p.waitForTimeout(800);
        const t3 = await p.locator('body').innerText();
        rec(`WEB-07-06@${w}`, /valid email/i.test(t3), `bad email message=${/valid email/i.test(t3)}`, await shot(p, `web07_bademail_${w}`));
      }
    }
    const sw = await p.evaluate(() => document.documentElement.scrollWidth - window.innerWidth);
    rec(`WEB-07-07@${w}`, sw <= 0, `horizontal overflow ${sw}px`);
    await c.close();
  }
};
