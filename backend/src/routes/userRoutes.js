
const express = require('express');
const router = express.Router();
const { register, login, getUserById } = require('../controllers/userController');

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

module.exports = router;
