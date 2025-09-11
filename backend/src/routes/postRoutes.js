
const express = require('express');
const router = express.Router();
const { createPost, getPosts, getPostById, deletePost, likePost, unlikePost, addComment, getPostsByUser, getComments, getRelatedPosts } = require('../controllers/postController');
const auth = require('../middleware/auth');

// @route   POST api/posts
// @desc    Create a post
// @access  Private
router.post('/', auth, createPost);

// @route   GET api/posts
// @desc    Get all posts
// @access  Public
router.get('/', getPosts);

// @route   GET api/posts/:id
// @desc    Get post by ID
// @access  Public
router.get('/:id', getPostById);

// @route   DELETE api/posts/:id
// @desc    Delete a post
// @access  Private
router.delete('/:id', auth, deletePost);

// @route   PUT api/posts/like/:id
// @desc    Like a post
// @access  Private
router.put('/like/:id', auth, likePost);

// @route   PUT api/posts/unlike/:id
// @desc    Unlike a post
// @access  Private
router.put('/unlike/:id', auth, unlikePost);

// @route   POST api/posts/comment/:id
// @desc    Comment on a post
// @access  Private
router.post('/comment/:id', auth, addComment);

// @route   GET api/posts/:id/comments
// @desc    Get comments for a post
// @access  Private (token optional as per app behavior)
router.get('/:id/comments', auth, getComments);

// @route   GET api/posts/user/:userId
// @desc    Get all posts by a specific user
// @access  Public
router.get('/user/:userId', getPostsByUser);

// @route   GET api/posts/:id/related
// @desc    Get related posts
// @access  Public
router.get('/:id/related', getRelatedPosts);

module.exports = router;
