// Transactional email over SMTP (Admin → API Keys → Email). Inactive until SMTP is configured.
const nodemailer = require('nodemailer');
const { getSetting } = require('./settings');

let cached = { sig: null, transport: null };
const getConfig = async () => {
  const [host, port, user, pass, from] = await Promise.all(['SMTP_HOST', 'SMTP_PORT', 'SMTP_USER', 'SMTP_PASS', 'EMAIL_FROM'].map(getSetting));
  return { host, port: parseInt(port || '587', 10), user, pass, from: from || user };
};
const isEmailConfigured = async () => { const c = await getConfig(); return !!(c.host && c.from); };

const transportFor = (c) => {
  const sig = JSON.stringify([c.host, c.port, c.user, c.pass]);
  if (cached.sig !== sig) {
    cached = { sig, transport: nodemailer.createTransport({
      host: c.host, port: c.port, secure: c.port === 465,
      auth: c.user ? { user: c.user, pass: c.pass } : undefined,
      connectionTimeout: 10000, greetingTimeout: 10000, socketTimeout: 15000,
    }) };
  }
  return cached.transport;
};

const esc = (v) => String(v ?? '').replace(/[&<>"]/g, (ch) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;' }[ch]));
/** Simple branded layout used by every ChillFi email. */
const layout = ({ title, body, ctaText, ctaUrl }) => `<!doctype html><html><body style="margin:0;background:#f5f5f7;font-family:Arial,Helvetica,sans-serif">
<table role="presentation" width="100%" cellpadding="0" cellspacing="0"><tr><td align="center" style="padding:24px 12px">
<table role="presentation" width="100%" style="max-width:560px;background:#fff;border-radius:16px;overflow:hidden">
<tr><td style="background:#FF6B2C;padding:18px 24px;color:#fff;font-size:20px;font-weight:bold">ChillFi</td></tr>
<tr><td style="padding:24px"><h1 style="margin:0 0 12px;font-size:20px;color:#111827">${esc(title)}</h1>
<p style="margin:0 0 20px;font-size:15px;line-height:1.5;color:#374151">${esc(body)}</p>
${ctaUrl ? `<a href="${esc(ctaUrl)}" style="display:inline-block;background:#6C2BFF;color:#fff;text-decoration:none;padding:12px 20px;border-radius:10px;font-weight:bold">${esc(ctaText || 'View order')}</a>` : ''}
</td></tr><tr><td style="padding:16px 24px;background:#fafafa;font-size:12px;color:#6b7280">You're receiving this because of activity on your ChillFi account.</td></tr>
</table></td></tr></table></body></html>`;

/** Never throws. Returns { sent, reason }. */
const sendMail = async ({ to, subject, title, body, ctaText, ctaUrl }) => {
  try {
    if (!to) return { sent: false, reason: 'no recipient' };
    const c = await getConfig();
    if (!c.host || !c.from) return { sent: false, reason: 'email not configured' };
    await transportFor(c).sendMail({
      from: c.from, to, subject,
      text: `${title || subject}\n\n${body}${ctaUrl ? `\n\n${ctaText || 'View order'}: ${ctaUrl}` : ''}`,
      html: layout({ title: title || subject, body, ctaText, ctaUrl }),
    });
    return { sent: true };
  } catch (err) {
    console.error(`[email] send failed to=${String(to).replace(/(.).*@/, '$1***@')}: ${err.message}`);
    return { sent: false, reason: 'send failed' };
  }
};

module.exports = { sendMail, isEmailConfigured, layout };
