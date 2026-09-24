const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const { initiatePayment, verifyPayment, confirmCOD, webhook, paymentCallback, devSuccess, DEV_AUTOPAY } = require('../controllers/paymentController');

router.post('/webhook', webhook);
router.get('/callback', paymentCallback);
if (DEV_AUTOPAY) {
  router.get('/dev-success', devSuccess);
}
router.use(authenticate);
router.post('/initiate', initiatePayment);
router.post('/verify', verifyPayment);
router.post('/cod-confirm', confirmCOD);

module.exports = router;
