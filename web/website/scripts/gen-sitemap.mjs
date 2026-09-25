// Writes public/sitemap.xml before each build: static pages + every active product (from the live API).
// If the API can't be reached, the static pages are still written — the build never fails because of this.
import { writeFileSync, readFileSync, existsSync } from 'node:fs';

const SITE = 'https://chillfi.in';
const envFile = existsSync('.env.production') ? readFileSync('.env.production', 'utf8') : '';
const API = (envFile.match(/^VITE_API_URL=(.*)$/m)?.[1] || `${SITE}/api`).trim();
const STATIC = ['/', '/products', '/categories', '/offers', '/about', '/contact', '/support',
  '/privacy-policy', '/terms', '/refund-policy', '/return-policy', '/shipping-policy'];

const urls = STATIC.map((p) => ({ loc: `${SITE}${p}`, priority: p === '/' ? '1.0' : '0.6' }));
try {
  for (let page = 1; page <= 20; page++) {
    const res = await fetch(`${API}/products?limit=100&page=${page}`, { signal: AbortSignal.timeout(10000) });
    const d = (await res.json()).data;
    for (const p of d.products) urls.push({ loc: `${SITE}/product/${p.id}`, priority: '0.8' });
    if (page >= (d.pages || 1)) break;
  }
} catch (e) {
  console.warn(`[sitemap] products skipped (${e.message}) — static pages only`);
}
const today = new Date().toISOString().slice(0, 10);
const xml = `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${
  urls.map((u) => `  <url><loc>${u.loc}</loc><lastmod>${today}</lastmod><priority>${u.priority}</priority></url>`).join('\n')}\n</urlset>\n`;
writeFileSync('public/sitemap.xml', xml);
console.log(`[sitemap] ${urls.length} URLs written`);
