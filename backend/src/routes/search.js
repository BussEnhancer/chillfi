const router = require('express').Router();
const { search, getSuggestions, getTrendingSearches } = require('../controllers/searchController');

router.get('/', search);
router.get('/suggestions', getSuggestions);
router.get('/trending', getTrendingSearches);

module.exports = router;
