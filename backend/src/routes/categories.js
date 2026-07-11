const router = require('express').Router();
const { authenticate, adminOnly } = require('../middleware/auth');
const {
  getCategories, getCategory, getSubcategories, getCategoryProducts,
  createCategory, updateCategory, deleteCategory,
} = require('../controllers/categoryController');

router.get('/', getCategories);
router.get('/:id', getCategory);
router.get('/:id/subcategories', getSubcategories);
router.get('/:id/products', getCategoryProducts);

router.post('/', authenticate, adminOnly, createCategory);
router.put('/:id', authenticate, adminOnly, updateCategory);
router.delete('/:id', authenticate, adminOnly, deleteCategory);

module.exports = router;
