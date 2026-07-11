const router = require('express').Router();
const { createContactMessage } = require('../controllers/contactController');

router.post('/', createContactMessage);

module.exports = router;
