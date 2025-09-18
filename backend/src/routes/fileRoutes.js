const express = require('express');
const router = express.Router();
const upload = require('../utils/fileUpload');
const { uploadFile, deleteFile } = require('../controllers/fileController');
const auth = require('../middleware/auth');

// @route   POST api/files/upload
// @desc    Upload a file
// @access  Private
router.post('/upload', auth, upload.single('file'), uploadFile);

// @route   DELETE api/files/:filename
// @desc    Delete a file
// @access  Private
router.delete('/:filename', auth, deleteFile);

module.exports = router;
