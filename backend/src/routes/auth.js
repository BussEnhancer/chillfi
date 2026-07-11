const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const {
  sendOtp, verifyOtpLogin, signup, login,
  forgotPassword, resetPassword, getMe, logout,
  refreshToken, saveFcmToken,
} = require('../controllers/authController');

// Per-phone rate limiting is handled inside sendOtp/checkOtpRateLimit (DB-backed)
router.post('/send-otp', sendOtp);
router.post('/verify-otp', verifyOtpLogin);
router.post('/signup', signup);
router.post('/login', login);
router.post('/forgot-password', forgotPassword);
router.post('/reset-password', resetPassword);
router.post('/refresh-token', refreshToken);

router.get('/me', authenticate, getMe);
router.post('/logout', authenticate, logout);
router.post('/fcm-token', authenticate, saveFcmToken);

module.exports = router;
