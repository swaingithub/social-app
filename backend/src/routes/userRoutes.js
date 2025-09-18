const express = require('express');
const router = express.Router();
const { register, login, getMe, getUserById, updateUser, followUser, unfollowUser, searchUsers, getFollowers, getFollowing, getBookmarkedPosts } = require('../controllers/userController');
const auth = require('../middleware/auth');

// @route   POST api/users/register
// @desc    Register user
// @access  Public
router.post('/register', register);

// @route   POST api/users/login
// @desc    Login user / Returns JWT
// @access  Public
router.post('/login', login);

// @route   GET api/users/me
// @desc    Get current user
// @access  Private
router.get('/me', auth, getMe);

// @route   GET api/users/me/bookmarks
// @desc    Get current user's bookmarked posts
// @access  Private
router.get('/me/bookmarks', auth, getBookmarkedPosts);

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

// @route   PUT api/users/profile (legacy)
router.put('/profile', auth, updateProfile);

// @route   PUT api/users/me (frontend expects this)
router.put('/me', auth, updateProfile);

// Extra routes to match frontend expectations
// @route   PUT api/users/follow/:id
router.put('/follow/:id', auth, followUser);

// @route   PUT api/users/unfollow/:id
router.put('/unfollow/:id', auth, unfollowUser);

module.exports = router;
