const router = require('express').Router();
const { authenticate, adminOnly } = require('../middleware/auth');
const { getBrands, getBrandProducts, createBrand, updateBrand } = require('../controllers/brandController');

router.get('/', getBrands);
router.get('/:id/products', getBrandProducts);
router.post('/', authenticate, adminOnly, createBrand);
router.put('/:id', authenticate, adminOnly, updateBrand);

module.exports = router;
