const pool = require('../db/pool');

const getWishlist = async (req, res, next) => {
  try {
    const { id: userId } = req.user;
    const result = await pool.query(`
      SELECT w.id, w.product_id, p.name, p.price, p.old_price, p.rating,
             p.stock, p.status, pi.url AS image
      FROM wishlist w
      JOIN products p ON p.id = w.product_id
      LEFT JOIN LATERAL (
        SELECT url FROM product_images WHERE product_id = p.id ORDER BY sort_order LIMIT 1
      ) pi ON true
      WHERE w.user_id = $1
      ORDER BY w.added_at DESC
    `, [userId]);
    res.json({ success: true, data: result.rows });
  } catch (err) { next(err); }
};

const toggleWishlist = async (req, res, next) => {
  try {
    const { id: userId } = req.user;
    const { product_id } = req.body;
    if (!product_id) return res.status(400).json({ success: false, message: 'product_id required' });

    const existing = await pool.query('SELECT id FROM wishlist WHERE user_id=$1 AND product_id=$2', [userId, product_id]);
    if (existing.rows.length > 0) {
      await pool.query('DELETE FROM wishlist WHERE user_id=$1 AND product_id=$2', [userId, product_id]);
      return res.json({ success: true, message: 'Removed from wishlist', data: { wishlisted: false } });
    }
    await pool.query('INSERT INTO wishlist (user_id, product_id) VALUES ($1,$2)', [userId, product_id]);
    res.json({ success: true, message: 'Added to wishlist', data: { wishlisted: true } });
  } catch (err) { next(err); }
};

const removeFromWishlist = async (req, res, next) => {
  try {
    const { id: userId } = req.user;
    const { id } = req.params;
    await pool.query('DELETE FROM wishlist WHERE id=$1 AND user_id=$2', [id, userId]);
    res.json({ success: true, message: 'Removed from wishlist' });
  } catch (err) { next(err); }
};

const isWishlisted = async (req, res, next) => {
  try {
    const { id: userId } = req.user;
    const { productId } = req.params;
    const result = await pool.query('SELECT id FROM wishlist WHERE user_id=$1 AND product_id=$2', [userId, productId]);
    res.json({ success: true, data: { wishlisted: result.rows.length > 0 } });
  } catch (err) { next(err); }
};

module.exports = { getWishlist, toggleWishlist, removeFromWishlist, isWishlisted };
