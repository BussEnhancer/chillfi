const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const {
  createOrder, getOrders, getOrder, cancelOrder, requestRefund,
  getOrderTracking, getInvoice } = require('../controllers/orderController');

router.use(authenticate);
router.post('/', createOrder);
router.get('/', getOrders);
// Admin order management is handled by /api/admin/orders (routes/admin.js).
// Parametric route /:id must stay after all static segments to avoid shadowing.
router.get('/:id', getOrder);
router.get('/:id/invoice', getInvoice);
router.get('/:id/tracking', getOrderTracking);
router.post('/:id/cancel', cancelOrder);
router.post('/:id/refund-request', requestRefund);

module.exports = router;
