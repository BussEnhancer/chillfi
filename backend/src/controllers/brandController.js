const pool = require('../db/pool');

// GET /api/brands
const getBrands = async (req, res) => {
  const adminList = String(req.baseUrl || '').endsWith('/admin'); // admin sees inactive brands too
  const result = await pool.query(`
    SELECT b.*, COUNT(DISTINCT p.id) as product_count
    FROM brands b
    LEFT JOIN products p ON p.brand_id = b.id AND p.status != 'Inactive'
    ${adminList ? '' : 'WHERE b.is_active = TRUE'}
    GROUP BY b.id
    ORDER BY product_count DESC
  `);
  res.json({ success: true, data: { brands: result.rows } });
};

// GET /api/brands/:id/products
const getBrandProducts = async (req, res) => {
  const { id } = req.params;
  const { page = 1, limit = 20 } = req.query;
  const offset = (page - 1) * limit;

  const result = await pool.query(`
    SELECT p.*, c.name as category_name,
      (SELECT url FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as primary_image
    FROM products p
    LEFT JOIN categories c ON p.category_id = c.id
    WHERE p.brand_id = $1 AND p.status != 'Inactive'
    ORDER BY p.created_at DESC
    LIMIT $2 OFFSET $3
  `, [id, limit, offset]);

  res.json({ success: true, data: { products: result.rows } });
};

// POST /api/admin/brands
const createBrand = async (req, res) => {
  const { name, logo_url } = req.body;
  if (!name) return res.status(400).json({ success: false, message: 'Name required' });
  const result = await pool.query(
    `INSERT INTO brands (name, logo_url) VALUES ($1, $2) RETURNING *`,
    [name, logo_url]
  );
  res.status(201).json({ success: true, data: { brand: result.rows[0] } });
};

// PUT /api/admin/brands/:id
const updateBrand = async (req, res) => {
  const { id } = req.params;
  const { name, logo_url, is_active } = req.body;
  const result = await pool.query(`
    UPDATE brands SET
      name = COALESCE($1, name),
      logo_url = COALESCE($2, logo_url),
      is_active = COALESCE($3, is_active)
    WHERE id = $4 RETURNING *
  `, [name, logo_url, is_active, id]);
  if (!result.rows.length) return res.status(404).json({ success: false, message: 'Not found' });
  res.json({ success: true, data: { brand: result.rows[0] } });
};

// DELETE /api/admin/brands/:id
const deleteBrand = async (req, res) => {
  const { id } = req.params;
  const result = await pool.query(`DELETE FROM brands WHERE id = $1 RETURNING id`, [id]);
  if (!result.rows.length) return res.status(404).json({ success: false, message: 'Not found' });
  res.json({ success: true });
};

module.exports = { getBrands, getBrandProducts, createBrand, updateBrand, deleteBrand };
