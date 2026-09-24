const pool = require('../db/pool');

// Accepts either a plain URL string or a { url } object (defensive against callers
// that pass the same shape the API returns elsewhere) and always returns a plain string.
const toImageUrl = (image) => {
  if (typeof image === 'string') return image;
  if (image && typeof image === 'object' && typeof image.url === 'string') return image.url;
  return null;
};

// GET /api/products
const getProducts = async (req, res) => {
  const {
    category, brand, search, status,
    sort = 'created_at', order = 'DESC',
    page = 1, limit = 20,
    min_price, max_price,
  } = req.query;

  const offset = (page - 1) * limit;
  const values = [];
  // The admin list (/api/admin/products) must also show Inactive products so they can be re-activated.
  const adminList = String(req.baseUrl || '').endsWith('/admin');
  const conditions = adminList ? [] : [`p.status != 'Inactive'`];

  if (status && status !== 'all') {
    values.push(status);
    conditions.push(`p.status = $${values.length}`);
  }
  if (category) {
    values.push(category);
    conditions.push(`(c.name ILIKE $${values.length} OR c.id::text = $${values.length})`);
  }
  if (brand) {
    values.push(brand);
    conditions.push(`(b.name ILIKE $${values.length} OR b.id::text = $${values.length})`);
  }
  if (search) {
    values.push(`%${search}%`);
    conditions.push(`(p.name ILIKE $${values.length} OR p.description ILIKE $${values.length})`);
  }
  if (min_price) { values.push(min_price); conditions.push(`p.price >= $${values.length}`); }
  if (max_price) { values.push(max_price); conditions.push(`p.price <= $${values.length}`); }

  const where = conditions.length ? `WHERE ${conditions.join(' AND ')}` : '';
  const allowedSort = { price: 'p.price', rating: 'p.rating', newest: 'p.created_at', name: 'p.name' };
  const sortCol = allowedSort[sort] || 'p.created_at';
  const sortDir = order.toUpperCase() === 'ASC' ? 'ASC' : 'DESC';

  const query = `
    SELECT p.*, b.name as brand_name, (SELECT name FROM categories WHERE id = p.category_id) as category_name, c.name as category_name,
      (SELECT url FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as primary_image,
      (SELECT json_agg(url ORDER BY sort_order) FROM product_images WHERE product_id = p.id) as images
    FROM products p
    LEFT JOIN brands b ON p.brand_id = b.id
    LEFT JOIN categories c ON p.category_id = c.id
    ${where}
    ORDER BY ${sortCol} ${sortDir}
    LIMIT $${values.length + 1} OFFSET $${values.length + 2}
  `;

  const countQuery = `
    SELECT COUNT(*) FROM products p
    LEFT JOIN brands b ON p.brand_id = b.id
    LEFT JOIN categories c ON p.category_id = c.id
    ${where}
  `;

  const [rows, count] = await Promise.all([
    pool.query(query, [...values, limit, offset]),
    pool.query(countQuery, values),
  ]);

  res.json({
    success: true,
    data: {
      products: rows.rows,
      total: parseInt(count.rows[0].count),
      page: parseInt(page),
      pages: Math.ceil(count.rows[0].count / limit),
    },
  });
};

// GET /api/products/:id
const getProduct = async (req, res) => {
  const { id } = req.params;
  const result = await pool.query(`
    SELECT p.*, b.name as brand_name, (SELECT name FROM categories WHERE id = p.category_id) as category_name, c.name as category_name,
      (SELECT json_agg(json_build_object('url', url, 'is_primary', is_primary) ORDER BY sort_order)
       FROM product_images WHERE product_id = p.id) as images
    FROM products p
    LEFT JOIN brands b ON p.brand_id = b.id
    LEFT JOIN categories c ON p.category_id = c.id
    WHERE p.id = $1
  `, [id]);

  if (!result.rows.length) return res.status(404).json({ success: false, message: 'Product not found' });
  res.json({ success: true, data: { product: result.rows[0] } });
};

// GET /api/products/trending
const getTrending = async (req, res) => {
  const { limit = 10 } = req.query;
  const result = await pool.query(`
    SELECT p.*, b.name as brand_name, (SELECT name FROM categories WHERE id = p.category_id) as category_name,
      (SELECT url FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as primary_image
    FROM products p LEFT JOIN brands b ON p.brand_id = b.id
    WHERE p.status IN ('Active', 'Low Stock')
    ORDER BY p.review_count DESC, p.rating DESC
    LIMIT $1
  `, [limit]);
  res.json({ success: true, data: { products: result.rows } });
};

// GET /api/products/new-arrivals
const getNewArrivals = async (req, res) => {
  const { limit = 10 } = req.query;
  const result = await pool.query(`
    SELECT p.*, b.name as brand_name, (SELECT name FROM categories WHERE id = p.category_id) as category_name,
      (SELECT url FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as primary_image
    FROM products p LEFT JOIN brands b ON p.brand_id = b.id
    WHERE p.status IN ('Active', 'Low Stock')
    ORDER BY p.created_at DESC
    LIMIT $1
  `, [limit]);
  res.json({ success: true, data: { products: result.rows } });
};

// GET /api/products/flash-sale
const getFlashSale = async (req, res) => {
  const { limit = 10 } = req.query;
  const result = await pool.query(`
    SELECT p.*, b.name as brand_name, (SELECT name FROM categories WHERE id = p.category_id) as category_name,
      ROUND(((p.old_price - p.price) / p.old_price * 100)) as discount_pct,
      (SELECT url FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as primary_image
    FROM products p LEFT JOIN brands b ON p.brand_id = b.id
    WHERE p.status IN ('Active', 'Low Stock') AND p.is_flash_sale = TRUE
      AND (p.flash_sale_ends_at IS NULL OR p.flash_sale_ends_at > NOW())
    ORDER BY discount_pct DESC
    LIMIT $1
  `, [limit]);
  res.json({ success: true, data: { products: result.rows } });
};

// GET /api/products/featured
const getFeatured = async (req, res) => {
  const { limit = 10 } = req.query;
  const result = await pool.query(`
    SELECT p.*, b.name as brand_name, (SELECT name FROM categories WHERE id = p.category_id) as category_name,
      (SELECT url FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as primary_image
    FROM products p LEFT JOIN brands b ON p.brand_id = b.id
    WHERE p.status IN ('Active', 'Low Stock') AND p.is_featured = TRUE
    ORDER BY p.rating DESC
    LIMIT $1
  `, [limit]);
  res.json({ success: true, data: { products: result.rows } });
};

// GET /api/products/recommended  (user-specific or top-rated fallback)
const getRecommended = async (req, res) => {
  const userId = req.user?.id;
  const { limit = 10 } = req.query;

  let result;
  if (userId) {
    // Recommend based on recently viewed categories
    result = await pool.query(`
      SELECT DISTINCT p.*, b.name as brand_name, (SELECT name FROM categories WHERE id = p.category_id) as category_name,
        (SELECT url FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as primary_image
      FROM products p
      LEFT JOIN brands b ON p.brand_id = b.id
      WHERE p.status IN ('Active', 'Low Stock')
        AND p.category_id IN (
          SELECT DISTINCT pr.category_id FROM recently_viewed rv
          JOIN products pr ON rv.product_id = pr.id
          WHERE rv.user_id = $1
        )
        AND p.id NOT IN (SELECT product_id FROM recently_viewed WHERE user_id = $1)
      ORDER BY p.rating DESC
      LIMIT $2
    `, [userId, limit]);

    if (!result.rows.length) {
      result = await pool.query(`
        SELECT p.*, b.name as brand_name, (SELECT name FROM categories WHERE id = p.category_id) as category_name,
          (SELECT url FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as primary_image
        FROM products p LEFT JOIN brands b ON p.brand_id = b.id
        WHERE p.status IN ('Active', 'Low Stock')
        ORDER BY p.rating DESC, p.review_count DESC
        LIMIT $1
      `, [limit]);
    }
  } else {
    result = await pool.query(`
      SELECT p.*, b.name as brand_name, (SELECT name FROM categories WHERE id = p.category_id) as category_name,
        (SELECT url FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as primary_image
      FROM products p LEFT JOIN brands b ON p.brand_id = b.id
      WHERE p.status IN ('Active', 'Low Stock')
      ORDER BY p.rating DESC, p.review_count DESC
      LIMIT $1
    `, [limit]);
  }

  res.json({ success: true, data: { products: result.rows } });
};

// GET /api/products/:id/reviews
const getReviews = async (req, res) => {
  const { id } = req.params;
  const { page = 1, limit = 10, rating } = req.query;
  const offset = (page - 1) * limit;
  const values = [id];
  let ratingFilter = '';
  if (rating) { values.push(rating); ratingFilter = `AND r.rating = $${values.length}`; }

  const result = await pool.query(`
    SELECT r.*, u.name as user_name, u.avatar_url
    FROM reviews r
    JOIN users u ON r.user_id = u.id
    WHERE r.product_id = $1 ${ratingFilter}
    ORDER BY r.created_at DESC
    LIMIT $${values.length + 1} OFFSET $${values.length + 2}
  `, [...values, limit, offset]);

  const stats = await pool.query(`
    SELECT
      COUNT(*) as total,
      ROUND(AVG(rating), 1) as avg_rating,
      COUNT(*) FILTER (WHERE rating = 5) as five_star,
      COUNT(*) FILTER (WHERE rating = 4) as four_star,
      COUNT(*) FILTER (WHERE rating = 3) as three_star,
      COUNT(*) FILTER (WHERE rating = 2) as two_star,
      COUNT(*) FILTER (WHERE rating = 1) as one_star,
      COUNT(*) FILTER (WHERE is_verified) as verified
    FROM reviews WHERE product_id = $1
  `, [id]);

  res.json({ success: true, data: { reviews: result.rows, stats: stats.rows[0] } });
};

// POST /api/products/:id/reviews
const addReview = async (req, res) => {
  const { id } = req.params;
  const { rating, title, body } = req.body;
  const reviewsSetting = await pool.query(`SELECT value FROM store_settings WHERE key = 'product_reviews_enabled'`);
  if (reviewsSetting.rows[0]?.value === 'false') {
    return res.status(403).json({ success: false, message: 'Reviews are turned off at the moment. Please try again later.' });
  }
  if (!rating || rating < 1 || rating > 5) {
    return res.status(400).json({ success: false, message: 'Rating 1-5 required' });
  }

  // A review is a "verified purchase" only when the reviewer has a delivered order containing this product.
  const purchase = await pool.query(`
    SELECT o.id FROM orders o JOIN order_items oi ON oi.order_id = o.id
    WHERE o.user_id = $1 AND oi.product_id = $2 AND o.status = 'Delivered'
    ORDER BY o.created_at DESC LIMIT 1
  `, [req.user.id, id]);
  const orderId = purchase.rows[0]?.id || null;

  const result = await pool.query(`
    INSERT INTO reviews (user_id, product_id, rating, title, body, order_id, is_verified)
    VALUES ($1, $2, $3, $4, $5, $6, $7)
    ON CONFLICT (user_id, product_id) DO UPDATE SET rating=$3, title=$4, body=$5, order_id=$6, is_verified=$7
    RETURNING *
  `, [req.user.id, id, rating, title, body, orderId, !!orderId]);

  // Update product rating
  await pool.query(`
    UPDATE products SET
      rating = (SELECT ROUND(AVG(rating), 1) FROM reviews WHERE product_id = $1),
      review_count = (SELECT COUNT(*) FROM reviews WHERE product_id = $1)
    WHERE id = $1
  `, [id]);

  res.status(201).json({ success: true, data: { review: result.rows[0] } });
};

// DELETE /api/products/:id/reviews/:reviewId
const deleteReview = async (req, res) => {
  const { id, reviewId } = req.params;
  const result = await pool.query(
    'DELETE FROM reviews WHERE id = $1 AND user_id = $2 AND product_id = $3 RETURNING id',
    [reviewId, req.user.id, id]
  );
  if (result.rowCount === 0) {
    return res.status(404).json({ success: false, message: 'Review not found or not yours' });
  }
  await pool.query(`
    UPDATE products SET
      rating = COALESCE((SELECT ROUND(AVG(rating), 1) FROM reviews WHERE product_id = $1), 0),
      review_count = (SELECT COUNT(*) FROM reviews WHERE product_id = $1)
    WHERE id = $1
  `, [id]);
  res.json({ success: true });
};

// POST /api/products/:id/recently-viewed
const logRecentlyViewed = async (req, res) => {
  const { id } = req.params;
  await pool.query(`
    INSERT INTO recently_viewed (user_id, product_id)
    VALUES ($1, $2)
    ON CONFLICT (user_id, product_id) DO UPDATE SET viewed_at = NOW()
  `, [req.user.id, id]);
  res.json({ success: true });
};

// GET /api/products/recently-viewed
const getRecentlyViewed = async (req, res) => {
  const { limit = 10 } = req.query;
  const result = await pool.query(`
    SELECT p.*, b.name as brand_name, (SELECT name FROM categories WHERE id = p.category_id) as category_name,
      (SELECT url FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as primary_image,
      rv.viewed_at
    FROM recently_viewed rv
    JOIN products p ON rv.product_id = p.id
    LEFT JOIN brands b ON p.brand_id = b.id
    WHERE rv.user_id = $1 AND p.status != 'Inactive'
    ORDER BY rv.viewed_at DESC
    LIMIT $2
  `, [req.user.id, limit]);
  res.json({ success: true, data: { products: result.rows } });
};

// DELETE /api/products/recently-viewed/:id
const removeRecentlyViewed = async (req, res) => {
  await pool.query('DELETE FROM recently_viewed WHERE user_id = $1 AND product_id = $2', [req.user.id, req.params.id]);
  res.json({ success: true });
};

// DELETE /api/products/recently-viewed
const clearRecentlyViewed = async (req, res) => {
  await pool.query('DELETE FROM recently_viewed WHERE user_id = $1', [req.user.id]);
  res.json({ success: true });
};

// ── ADMIN CRUD ──────────────────────────────────────────────

// Admin form sends brand/category by NAME; resolve to ids (brand is created if it doesn't exist yet).
const resolveRefs = async (body) => {
  const out = {};
  if (body.category_id) out.category_id = body.category_id;
  else if (body.category_name) {
    const c = await pool.query('SELECT id FROM categories WHERE LOWER(name) = LOWER($1) LIMIT 1', [String(body.category_name).trim()]);
    if (!c.rows.length) { const e = new Error(`Category "${body.category_name}" doesn't exist. Create it in Categories first.`); e.status = 400; throw e; }
    out.category_id = c.rows[0].id;
  }
  if (body.brand_id) out.brand_id = body.brand_id;
  else if (body.brand_name && String(body.brand_name).trim()) {
    const name = String(body.brand_name).trim();
    const b = await pool.query('SELECT id FROM brands WHERE LOWER(name) = LOWER($1) LIMIT 1', [name]);
    out.brand_id = b.rows.length ? b.rows[0].id
      : (await pool.query('INSERT INTO brands (name, is_active) VALUES ($1, TRUE) RETURNING id', [name])).rows[0].id;
  }
  return out;
};

// POST /api/admin/products
const createProduct = async (req, res) => {
  const { name, description, price, old_price, stock,
    status = 'Active', is_featured = false, is_flash_sale = false,
    flash_sale_ends_at, tags } = req.body;
  const images = req.body.images || (req.body.image ? [req.body.image] : []);

  if (!name || !String(name).trim()) return res.status(400).json({ success: false, message: 'Product name is required' });
  if (!(Number(price) > 0)) return res.status(400).json({ success: false, message: 'Selling price must be greater than 0' });
  if (old_price != null && old_price !== '' && Number(old_price) > 0 && Number(old_price) < Number(price)) {
    return res.status(400).json({ success: false, message: 'MRP cannot be lower than the selling price' });
  }
  if (stock != null && Number(stock) < 0) return res.status(400).json({ success: false, message: 'Stock cannot be negative' });
  const { brand_id, category_id } = await resolveRefs(req.body);
  if (!category_id) return res.status(400).json({ success: false, message: 'Please choose a category' });

  const result = await pool.query(`
    INSERT INTO products (name, description, price, old_price, stock, brand_id, category_id,
      status, is_featured, is_flash_sale, flash_sale_ends_at, tags)
    VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
    RETURNING *
  `, [name, description, price, old_price, stock, brand_id, category_id,
    status, is_featured, is_flash_sale, flash_sale_ends_at, tags]);

  const product = result.rows[0];

  // Insert images
  if (images.length) {
    let sortOrder = 0;
    for (const raw of images) {
      const url = toImageUrl(raw);
      if (!url) continue;
      await pool.query(
        `INSERT INTO product_images (product_id, url, is_primary, sort_order) VALUES ($1, $2, $3, $4)`,
        [product.id, url, sortOrder === 0, sortOrder]
      );
      sortOrder++;
    }
  }

  res.status(201).json({ success: true, data: { product } });
};

// PUT /api/admin/products/:id
const updateProduct = async (req, res) => {
  const { id } = req.params;
  const { name, description, price, old_price, stock,
    status, is_featured, is_flash_sale, flash_sale_ends_at, tags } = req.body;
  const images = req.body.images || (req.body.image ? [req.body.image] : undefined);
  if (price != null && !(Number(price) > 0)) return res.status(400).json({ success: false, message: 'Selling price must be greater than 0' });
  if (stock != null && Number(stock) < 0) return res.status(400).json({ success: false, message: 'Stock cannot be negative' });
  if (status != null && !['Active', 'Inactive', 'Out of Stock', 'Low Stock'].includes(status)) {
    return res.status(400).json({ success: false, message: 'Invalid status' });
  }
  const { brand_id, category_id } = await resolveRefs(req.body);

  const result = await pool.query(`
    UPDATE products SET
      name = COALESCE($1, name), description = COALESCE($2, description),
      price = COALESCE($3, price), old_price = COALESCE($4, old_price),
      stock = COALESCE($5, stock), brand_id = COALESCE($6, brand_id),
      category_id = COALESCE($7, category_id), status = COALESCE($8, status),
      is_featured = COALESCE($9, is_featured), is_flash_sale = COALESCE($10, is_flash_sale),
      flash_sale_ends_at = COALESCE($11, flash_sale_ends_at), tags = COALESCE($12, tags),
      updated_at = NOW()
    WHERE id = $13 RETURNING *
  `, [name, description, price, old_price, stock, brand_id, category_id,
    status, is_featured, is_flash_sale, flash_sale_ends_at, tags, id]);

  if (!result.rows.length) return res.status(404).json({ success: false, message: 'Product not found' });

  if (images?.length) {
    await pool.query(`DELETE FROM product_images WHERE product_id = $1`, [id]);
    let sortOrder = 0;
    for (const raw of images) {
      const url = toImageUrl(raw);
      if (!url) continue;
      await pool.query(
        `INSERT INTO product_images (product_id, url, is_primary, sort_order) VALUES ($1, $2, $3, $4)`,
        [id, url, sortOrder === 0, sortOrder]
      );
      sortOrder++;
    }
  }

  res.json({ success: true, data: { product: result.rows[0] } });
};

// DELETE /api/admin/products/:id
const deleteProduct = async (req, res) => {
  const { id } = req.params;
  // Soft delete: products referenced by past orders must keep existing. Re-activate by setting status Active.
  await pool.query(`UPDATE products SET status = 'Inactive', updated_at = NOW() WHERE id = $1`, [id]);
  res.json({ success: true, message: 'Product deactivated (hidden from the store). Set it Active again to restore.' });
};

module.exports = {
  getProducts, getProduct, getTrending, getNewArrivals, getFlashSale,
  getFeatured, getRecommended, getReviews, addReview, deleteReview,
  logRecentlyViewed, getRecentlyViewed, removeRecentlyViewed, clearRecentlyViewed,
  createProduct, updateProduct, deleteProduct,
};
