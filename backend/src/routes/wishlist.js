const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const { getWishlist, toggleWishlist, removeFromWishlist, isWishlisted } = require('../controllers/wishlistController');

router.use(authenticate);
router.get('/', getWishlist);
router.post('/toggle', toggleWishlist);
router.delete('/:id', removeFromWishlist);
router.get('/check/:productId', isWishlisted);

module.exports = router;
