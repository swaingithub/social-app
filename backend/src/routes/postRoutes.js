const express = require('express');
const router = express.Router();
const { createPost, getPosts } = require('../controllers/postController');
const auth = require('../middleware/auth');

// @route   POST api/posts
// @desc    Create a post
// @access  Private
router.post('/', auth, createPost);

// @route   GET api/posts
// @desc    Get all posts
// @access  Public
router.get('/', getPosts);

module.exports = router;
