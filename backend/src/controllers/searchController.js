const pool = require('../db/pool');

// GET /api/search?q=
const search = async (req, res) => {
  const { q, page = 1, limit = 20 } = req.query;
  if (!q || q.trim().length < 2) {
    return res.status(400).json({ success: false, message: 'Query must be at least 2 characters' });
  }

  const offset = (page - 1) * limit;
  const term = `%${q.trim()}%`;

  const [products, categories, brands] = await Promise.all([
    pool.query(`
      SELECT p.id, p.name, p.price, p.old_price, p.rating, p.review_count, p.status,
        b.name as brand_name, c.name as category_name,
        (SELECT url FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as primary_image
      FROM products p
      LEFT JOIN brands b ON p.brand_id = b.id
      LEFT JOIN categories c ON p.category_id = c.id
      WHERE p.status != 'Inactive'
        AND (p.name ILIKE $1 OR p.description ILIKE $1 OR b.name ILIKE $1 OR c.name ILIKE $1)
      ORDER BY p.rating DESC
      LIMIT $2 OFFSET $3
    `, [term, limit, offset]),

    pool.query(`
      SELECT id, name, icon, image_url FROM categories
      WHERE is_active = TRUE AND name ILIKE $1 AND parent_id IS NULL
      LIMIT 5
    `, [term]),

    pool.query(`
      SELECT id, name, logo_url FROM brands
      WHERE is_active = TRUE AND name ILIKE $1
      LIMIT 5
    `, [term]),
  ]);

  const count = await pool.query(`
    SELECT COUNT(*) FROM products p
    LEFT JOIN brands b ON p.brand_id = b.id
    LEFT JOIN categories c ON p.category_id = c.id
    WHERE p.status != 'Inactive'
      AND (p.name ILIKE $1 OR p.description ILIKE $1 OR b.name ILIKE $1 OR c.name ILIKE $1)
  `, [term]);

  // Log search
  if (req.user?.id) {
    pool.query(
      `INSERT INTO search_logs (user_id, query, results_count) VALUES ($1, $2, $3)`,
      [req.user.id, q.trim(), count.rows[0].count]
    ).catch(() => {});
  }

  res.json({
    success: true,
    data: {
      query: q,
      products: products.rows,
      categories: categories.rows,
      brands: brands.rows,
      total: parseInt(count.rows[0].count),
      page: parseInt(page),
      pages: Math.ceil(count.rows[0].count / limit),
    },
  });
};

// GET /api/search/suggestions?q=
const getSuggestions = async (req, res) => {
  const { q } = req.query;
  if (!q || q.length < 1) return res.json({ success: true, data: { suggestions: [] } });

  const term = `${q.trim()}%`;
  const result = await pool.query(`
    (SELECT name, 'product' as type FROM products WHERE name ILIKE $1 AND status != 'Inactive' LIMIT 4)
    UNION
    (SELECT name, 'category' as type FROM categories WHERE name ILIKE $1 AND is_active = TRUE LIMIT 3)
    UNION
    (SELECT name, 'brand' as type FROM brands WHERE name ILIKE $1 AND is_active = TRUE LIMIT 3)
    LIMIT 8
  `, [term]);

  res.json({ success: true, data: { suggestions: result.rows } });
};

// GET /api/search/trending
const getTrendingSearches = async (req, res) => {
  const result = await pool.query(`
    SELECT query, COUNT(*) as count
    FROM search_logs
    WHERE searched_at > NOW() - INTERVAL '7 days'
    GROUP BY query
    ORDER BY count DESC
    LIMIT 10
  `);

  // Fallback defaults if no logs yet
  const defaults = [
    'Samsung', 'iPhone', 'Laptop', 'Earbuds', 'Smart TV',
    'Gaming', 'Camera', 'Tablet', 'Smartwatch', 'Keyboard',
  ];

  const searches = result.rows.length
    ? result.rows.map(r => r.query)
    : defaults;

  res.json({ success: true, data: { trending: searches } });
};

module.exports = { search, getSuggestions, getTrendingSearches };
