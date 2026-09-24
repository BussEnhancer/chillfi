/**
 * Recomputes products.rating / products.review_count from the real reviews table.
 * Only touches these two derived columns; idempotent and safe to re-run.
 *   node scripts/recalc-ratings.js            → dry run (prints what would change)
 *   node scripts/recalc-ratings.js --apply    → writes the changes
 */
require('dotenv').config({ quiet: true });
const pool = require('../src/db/pool');

(async () => {
  const apply = process.argv.includes('--apply');
  const { rows } = await pool.query(`
    SELECT p.id, p.name, p.rating AS old_rating, p.review_count AS old_count,
           COALESCE(ROUND(AVG(r.rating), 1), 0) AS new_rating, COUNT(r.id)::int AS new_count
    FROM products p LEFT JOIN reviews r ON r.product_id = p.id
    GROUP BY p.id
    HAVING p.review_count <> COUNT(r.id) OR p.rating <> COALESCE(ROUND(AVG(r.rating), 1), 0)`);
  for (const r of rows) console.log(`${r.name}: ${r.old_rating} (${r.old_count}) → ${r.new_rating} (${r.new_count})`);
  if (apply && rows.length) {
    await pool.query(`
      UPDATE products p SET
        rating = COALESCE((SELECT ROUND(AVG(rating), 1) FROM reviews WHERE product_id = p.id), 0),
        review_count = (SELECT COUNT(*) FROM reviews WHERE product_id = p.id)`);
  }
  console.log(`${rows.length} product(s) ${apply ? 'updated' : 'would change (dry run; pass --apply)'}`);
  await pool.end();
})().catch((e) => { console.error(e.message); process.exit(1); });
