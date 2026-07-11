const router = require('express').Router();
const { getHomeData } = require('../controllers/homeController');

router.get('/', getHomeData);

module.exports = router;
