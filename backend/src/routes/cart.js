const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const { getCart, addToCart, updateCartItem, removeCartItem, clearCart, applyCoupon, getActiveCoupons } = require('../controllers/cartController');

router.get('/coupons', getActiveCoupons);
router.use(authenticate);
router.get('/', getCart);
router.post('/add', addToCart);
router.put('/item/:id', updateCartItem);
router.delete('/item/:id', removeCartItem);
router.delete('/clear', clearCart);
router.post('/apply-coupon', applyCoupon);

module.exports = router;
