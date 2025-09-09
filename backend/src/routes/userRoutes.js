
const express = require('express');
const router = express.Router();
const { register, login, getUserById, followUser, unfollowUser, updateUserSettings } = require('../controllers/userController');
const auth = require('../middleware/auth');

// @route   POST api/users/register
// @desc    Register user
// @access  Public
router.post('/register', register);

// @route   POST api/users/login
// @desc    Login user / Returns JWT
// @access  Public
router.post('/login', login);

// @route   GET api/users/:id
// @desc    Get user by ID
// @access  Public
router.get('/:id', getUserById);

// @route   POST api/users/:id/follow
// @desc    Follow a user
// @access  Private
router.post('/:id/follow', auth, followUser);

// @route   DELETE api/users/:id/follow
// @desc    Unfollow a user
// @access  Private
router.delete('/:id/follow', auth, unfollowUser);

// @route   PUT api/users/settings
// @desc    Update user settings
// @access  Private
router.put('/settings', auth, updateUserSettings);

module.exports = router;
