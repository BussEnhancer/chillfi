const pool = require('../db/pool');

// GET /api/home  — single call returns everything the Home screen needs
const getHomeData = async (req, res) => {
  const [banners, categories, flashSale, trending, featured, brands, testimonials, promoBanners] = await Promise.all([
    pool.query(`SELECT * FROM banners WHERE is_active = TRUE ORDER BY sort_order ASC`),

    pool.query(`
      SELECT c.id, c.name, c.icon, c.image_url
      FROM categories c
      WHERE c.parent_id IS NULL AND c.is_active = TRUE
      ORDER BY c.sort_order ASC LIMIT 8
    `),

    pool.query(`
      SELECT p.id, p.name, p.price, p.old_price, p.rating, p.review_count,
        ROUND(((p.old_price - p.price) / NULLIF(p.old_price, 0) * 100)) as discount_pct,
        (SELECT url FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as primary_image,
        p.flash_sale_ends_at
      FROM products p
      WHERE p.status = 'Active' AND p.is_flash_sale = TRUE
        AND (p.flash_sale_ends_at IS NULL OR p.flash_sale_ends_at > NOW())
      ORDER BY discount_pct DESC LIMIT 6
    `),

    pool.query(`
      SELECT p.id, p.name, p.price, p.old_price, p.rating, p.review_count,
        b.name as brand_name,
        (SELECT url FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as primary_image
      FROM products p LEFT JOIN brands b ON p.brand_id = b.id
      WHERE p.status = 'Active'
      ORDER BY p.review_count DESC, p.rating DESC LIMIT 8
    `),

    pool.query(`
      SELECT p.id, p.name, p.price, p.old_price, p.rating,
        b.name as brand_name,
        (SELECT url FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as primary_image
      FROM products p LEFT JOIN brands b ON p.brand_id = b.id
      WHERE p.status = 'Active' AND p.is_featured = TRUE
      ORDER BY p.rating DESC LIMIT 6
    `),

    pool.query(`SELECT id, name, logo_url FROM brands WHERE is_active = TRUE LIMIT 8`),

    pool.query(`SELECT * FROM testimonials WHERE is_active = TRUE ORDER BY sort_order ASC`),

    pool.query(`SELECT * FROM promo_banners WHERE is_active = TRUE ORDER BY sort_order ASC`),
  ]);

  res.json({
    success: true,
    data: {
      banners: banners.rows,
      categories: categories.rows,
      flash_sale: flashSale.rows,
      trending: trending.rows,
      featured: featured.rows,
      brands: brands.rows,
      testimonials: testimonials.rows,
      promo_banners: promoBanners.rows,
    },
  });
};

module.exports = { getHomeData };
