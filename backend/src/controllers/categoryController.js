const pool = require('../db/pool');

// GET /api/categories
const getCategories = async (req, res) => {
  const result = await pool.query(`
    SELECT c.*,
      COUNT(DISTINCT p.id) as product_count
    FROM categories c
    LEFT JOIN products p ON p.category_id = c.id AND p.status != 'Inactive'
    WHERE c.parent_id IS NULL AND c.is_active = TRUE
    GROUP BY c.id
    ORDER BY c.sort_order ASC, c.name ASC
  `);
  res.json({ success: true, data: { categories: result.rows } });
};

// GET /api/categories/:id
const getCategory = async (req, res) => {
  const { id } = req.params;
  const result = await pool.query(`
    SELECT c.*, COUNT(DISTINCT p.id) as product_count
    FROM categories c
    LEFT JOIN products p ON p.category_id = c.id AND p.status != 'Inactive'
    WHERE c.id = $1
    GROUP BY c.id
  `, [id]);
  if (!result.rows.length) return res.status(404).json({ success: false, message: 'Category not found' });
  res.json({ success: true, data: { category: result.rows[0] } });
};

// GET /api/categories/:id/subcategories
const getSubcategories = async (req, res) => {
  const { id } = req.params;
  const result = await pool.query(`
    SELECT c.*, COUNT(DISTINCT p.id) as product_count
    FROM categories c
    LEFT JOIN products p ON p.category_id = c.id AND p.status != 'Inactive'
    WHERE c.parent_id = $1 AND c.is_active = TRUE
    GROUP BY c.id
    ORDER BY c.sort_order ASC, c.name ASC
  `, [id]);
  res.json({ success: true, data: { subcategories: result.rows } });
};

// GET /api/categories/:id/products
const getCategoryProducts = async (req, res) => {
  const { id } = req.params;
  const { page = 1, limit = 20, sort = 'created_at', order = 'DESC' } = req.query;
  const offset = (page - 1) * limit;

  const allowedSort = { price: 'p.price', rating: 'p.rating', newest: 'p.created_at' };
  const sortCol = allowedSort[sort] || 'p.created_at';
  const sortDir = order.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';

  const result = await pool.query(`
    SELECT p.*, b.name as brand_name,
      (SELECT url FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as primary_image
    FROM products p
    LEFT JOIN brands b ON p.brand_id = b.id
    WHERE p.category_id = $1 AND p.status != 'Inactive'
    ORDER BY ${sortCol} ${sortDir}
    LIMIT $2 OFFSET $3
  `, [id, limit, offset]);

  const count = await pool.query(`SELECT COUNT(*) FROM products WHERE category_id = $1 AND status != 'Inactive'`, [id]);

  res.json({
    success: true,
    data: {
      products: result.rows,
      total: parseInt(count.rows[0].count),
      page: parseInt(page),
      pages: Math.ceil(count.rows[0].count / limit),
    },
  });
};

// ── ADMIN CRUD ──────────────────────────────────────────────

const createCategory = async (req, res) => {
  const { name, icon, description, parent_id, image_url, sort_order = 0 } = req.body;
  if (!name) return res.status(400).json({ success: false, message: 'Name required' });
  const result = await pool.query(`
    INSERT INTO categories (name, icon, description, parent_id, image_url, sort_order)
    VALUES ($1,$2,$3,$4,$5,$6) RETURNING *
  `, [name, icon, description, parent_id || null, image_url, sort_order]);
  res.status(201).json({ success: true, data: { category: result.rows[0] } });
};

const updateCategory = async (req, res) => {
  const { id } = req.params;
  const { name, icon, description, parent_id, image_url, is_active, sort_order } = req.body;
  const result = await pool.query(`
    UPDATE categories SET
      name = COALESCE($1, name), icon = COALESCE($2, icon),
      description = COALESCE($3, description), parent_id = COALESCE($4, parent_id),
      image_url = COALESCE($5, image_url), is_active = COALESCE($6, is_active),
      sort_order = COALESCE($7, sort_order)
    WHERE id = $8 RETURNING *
  `, [name, icon, description, parent_id, image_url, is_active, sort_order, id]);
  if (!result.rows.length) return res.status(404).json({ success: false, message: 'Not found' });
  res.json({ success: true, data: { category: result.rows[0] } });
};

const deleteCategory = async (req, res) => {
  const { id } = req.params;
  await pool.query(`UPDATE categories SET is_active = FALSE WHERE id = $1`, [id]);
  res.json({ success: true, message: 'Category deactivated' });
};

module.exports = {
  getCategories, getCategory, getSubcategories, getCategoryProducts,
  createCategory, updateCategory, deleteCategory,
};
