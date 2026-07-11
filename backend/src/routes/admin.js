const router = require('express').Router();
const { authenticate, adminOnly, staffOrAdmin } = require('../middleware/auth');
const { upload } = require('../middleware/upload');
const {
  getDashboardStats, getAnalytics,
  getUsers, updateUserStatus, updateUserRole,
  getBanners, createBanner, updateBanner, deleteBanner,
  getShippingRules, createShippingRule, updateShippingRule, deleteShippingRule,
  getTestimonials, createTestimonial, updateTestimonial, deleteTestimonial,
  getPromoBanners, createPromoBanner, updatePromoBanner, deletePromoBanner,
  getCoupons, createCoupon, updateCoupon, deleteCoupon,
  getReviews, deleteReview,
  getMessages, updateMessageReadStatus, replyToMessage, deleteMessage,
  getSettings, updateSettings,
  getCredentials, updateCredentials,
  uploadImage, deleteImage,
  sendPushNotification,
} = require('../controllers/adminController');
const {
  getProducts, getProduct, createProduct, updateProduct, deleteProduct,
} = require('../controllers/productController');
const {
  getCategories, createCategory, updateCategory, deleteCategory,
} = require('../controllers/categoryController');
const {
  adminGetOrders, adminUpdateStatus, adminGetRefunds, adminUpdateRefund,
  adminShipOrder, adminTrackOrder,
} = require('../controllers/orderController');

router.use(authenticate, staffOrAdmin);

// Dashboard & Analytics — admin only
router.get('/dashboard', adminOnly, getDashboardStats);
router.get('/analytics', adminOnly, getAnalytics);

// Users — admin only
router.get('/users', adminOnly, getUsers);
router.put('/users/:id/status', adminOnly, updateUserStatus);
router.put('/users/:id/role', adminOnly, updateUserRole);

// Banners — admin only
router.get('/banners', adminOnly, getBanners);
router.post('/banners', adminOnly, createBanner);
router.put('/banners/:id', adminOnly, updateBanner);
router.delete('/banners/:id', adminOnly, deleteBanner);

// Shipping Rules — admin only
router.get('/shipping-rules', adminOnly, getShippingRules);
router.post('/shipping-rules', adminOnly, createShippingRule);
router.put('/shipping-rules/:id', adminOnly, updateShippingRule);
router.delete('/shipping-rules/:id', adminOnly, deleteShippingRule);

// Coupons — admin only
router.get('/coupons', adminOnly, getCoupons);
router.post('/coupons', adminOnly, createCoupon);
router.put('/coupons/:id', adminOnly, updateCoupon);
router.delete('/coupons/:id', adminOnly, deleteCoupon);

// Testimonials — admin only
router.get('/testimonials', adminOnly, getTestimonials);
router.post('/testimonials', adminOnly, createTestimonial);
router.put('/testimonials/:id', adminOnly, updateTestimonial);
router.delete('/testimonials/:id', adminOnly, deleteTestimonial);

// Promo Banners — admin only
router.get('/promo-banners', adminOnly, getPromoBanners);
router.post('/promo-banners', adminOnly, createPromoBanner);
router.put('/promo-banners/:id', adminOnly, updatePromoBanner);
router.delete('/promo-banners/:id', adminOnly, deletePromoBanner);

// Reviews — staff or admin (moderation)
router.get('/reviews', getReviews);
router.delete('/reviews/:id', deleteReview);

// Contact Messages — staff or admin
router.get('/messages', getMessages);
router.put('/messages/:id/read', updateMessageReadStatus);
router.post('/messages/:id/reply', replyToMessage);
router.delete('/messages/:id', deleteMessage);

// Settings — admin only
router.get('/settings', adminOnly, getSettings);
router.put('/settings', adminOnly, updateSettings);
router.get('/credentials', adminOnly, getCredentials);
router.put('/credentials', adminOnly, updateCredentials);

// Image upload — admin only
router.post('/upload', adminOnly, upload.single('image'), uploadImage);
router.delete('/upload', adminOnly, deleteImage);

// Push notifications — admin only
router.post('/notify', adminOnly, sendPushNotification);

// Products — admin CRUD
router.get('/products', adminOnly, getProducts);
router.post('/products', adminOnly, upload.single('image'), createProduct);
router.put('/products/:id', adminOnly, upload.single('image'), updateProduct);
router.delete('/products/:id', adminOnly, deleteProduct);

// Categories — admin CRUD
router.get('/categories', adminOnly, getCategories);
router.post('/categories', adminOnly, createCategory);
router.put('/categories/:id', adminOnly, updateCategory);
router.delete('/categories/:id', adminOnly, deleteCategory);

// Orders — staff can view, admin can update/ship
router.get('/orders', staffOrAdmin, adminGetOrders);
router.put('/orders/:id/status', adminOnly, adminUpdateStatus);
router.post('/orders/:id/ship', adminOnly, adminShipOrder);
router.get('/orders/:id/tracking', staffOrAdmin, adminTrackOrder);

// Refund requests — staff can view, admin can update
router.get('/refund-requests', staffOrAdmin, adminGetRefunds);
router.put('/refund-requests/:id', adminOnly, adminUpdateRefund);

module.exports = router;
