
const express = require('express');
const router = express.Router();
const { getFeed } = require('../controllers/feedController');
const auth = require('../middleware/auth');

// @route   GET api/feed
// @desc    Get user's feed
// @access  Private
router.get('/', auth, getFeed);

module.exports = router;
