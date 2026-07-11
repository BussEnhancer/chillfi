const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const { upload } = require('../middleware/upload');
const {
  getProfile, updateProfile, uploadAvatar, getMyReviews, getNotifications, getUnreadNotificationCount,
  getNotificationPreferences, updateNotificationPreferences,
} = require('../controllers/profileController');

router.use(authenticate);
router.get('/', getProfile);
router.put('/', updateProfile);
router.post('/avatar', upload.single('avatar'), uploadAvatar);
router.get('/reviews', getMyReviews);
router.get('/notifications', getNotifications);
router.get('/notifications/unread-count', getUnreadNotificationCount);
router.get('/notification-preferences', getNotificationPreferences);
router.put('/notification-preferences', updateNotificationPreferences);

module.exports = router;
