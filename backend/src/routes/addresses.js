const router = require('express').Router();
const { authenticate } = require('../middleware/auth');
const { getAddresses, createAddress, updateAddress, deleteAddress, setDefault } = require('../controllers/addressController');

router.use(authenticate);
router.get('/', getAddresses);
router.post('/', createAddress);
router.put('/:id', updateAddress);
router.delete('/:id', deleteAddress);
router.put('/:id/set-default', setDefault);

module.exports = router;
