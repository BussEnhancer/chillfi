const router = require('express').Router();
const { authenticate, optionalAuthenticate, adminOnly } = require('../middleware/auth');
const {
  getProducts, getProduct, getTrending, getNewArrivals, getFlashSale,
  getFeatured, getRecommended, getReviews, addReview, deleteReview,
  logRecentlyViewed, getRecentlyViewed, removeRecentlyViewed, clearRecentlyViewed,
  createProduct, updateProduct, deleteProduct,
} = require('../controllers/productController');

// Public
router.get('/', getProducts);
router.get('/trending', getTrending);
router.get('/new-arrivals', getNewArrivals);
router.get('/flash-sale', getFlashSale);
router.get('/featured', getFeatured);
router.get('/recommended', optionalAuthenticate, getRecommended);
router.get('/recently-viewed', authenticate, getRecentlyViewed);
router.delete('/recently-viewed', authenticate, clearRecentlyViewed);
router.delete('/recently-viewed/:id', authenticate, removeRecentlyViewed);
router.get('/:id', getProduct);
router.get('/:id/reviews', getReviews);

// Authenticated
router.post('/:id/reviews', authenticate, addReview);
router.delete('/:id/reviews/:reviewId', authenticate, deleteReview);
router.post('/:id/recently-viewed', authenticate, logRecentlyViewed);

// Admin
router.post('/', authenticate, adminOnly, createProduct);
router.put('/:id', authenticate, adminOnly, updateProduct);
router.delete('/:id', authenticate, adminOnly, deleteProduct);

module.exports = router;
