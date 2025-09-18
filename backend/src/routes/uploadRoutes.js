const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const auth = require('../middleware/auth');
const { uploadFile, deleteFile } = require('../controllers/fileController');

// File filter to allow only images
const fileFilter = (req, file, cb) => {
  const filetypes = /jpe?g|png|gif/;
  const extname = filetypes.test(path.extname(file.originalname).toLowerCase());
  const mimetype = filetypes.test(file.mimetype);

  if (mimetype && extname) {
    return cb(null, true);
  } else {
    cb(new Error('Only .jpg, .jpeg, .png, and .gif files are allowed!'));
  }
};

// Configure multer storage
const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    const uploadsDir = path.join(__dirname, '../../uploads');
    if (!fs.existsSync(uploadsDir)) {
      fs.mkdirSync(uploadsDir, { recursive: true });
    }
    cb(null, uploadsDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, 'img-' + uniqueSuffix + path.extname(file.originalname).toLowerCase());
  }
});

// Create multer upload middleware
const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: { fileSize: 5 * 1024 * 1024 } // 5MB limit
});

// Upload route with error handling
router.post('/upload', auth, (req, res) => {
  upload.single('file')(req, res, function (err) {
    if (err) {
      console.error('Upload error:', err);
      if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(413).json({ success: false, msg: 'File size too large. Maximum size is 5MB.' });
      } else if (err.message.includes('file type')) {
        return res.status(400).json({ success: false, msg: 'Invalid file type. Only images are allowed.' });
      }
      return res.status(500).json({ success: false, msg: 'File upload failed' });
    }
    
    if (!req.file) {
      return res.status(400).json({ success: false, msg: 'No file uploaded' });
    }
    
    // If we get here, the file was uploaded successfully
    uploadFile(req, res);
  });
});

// Delete route
router.delete('/:filename', auth, deleteFile);

module.exports = router;
