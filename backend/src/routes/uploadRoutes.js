const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const fs = require('fs');
const auth = require('../middleware/auth');

const uploadsDir = path.join(__dirname, '../../uploads');
if (!fs.existsSync(uploadsDir)) {
  fs.mkdirSync(uploadsDir, { recursive: true });
}

const storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, uploadsDir);
  },
  filename: function (req, file, cb) {
    const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1e9);
    cb(null, uniqueSuffix + path.extname(file.originalname));
  }
});

const upload = multer({ storage }).single('file');

router.post('/upload', auth, (req, res) => {
  console.log('Upload request received');
  upload(req, res, function (err) {
    if (err instanceof multer.MulterError) {
      console.error('Multer error:', err);
      return res.status(500).json({ msg: 'A Multer error occurred when uploading.' });
    } else if (err) {
      console.error('Unknown error during upload:', err);
      return res.status(500).json({ msg: 'An unknown error occurred when uploading.' });
    }

    if (!req.file) {
      console.log('No file uploaded');
      return res.status(400).json({ msg: 'No file uploaded' });
    }

    console.log('File uploaded successfully:', req.file);
    const fileUrl = `/uploads/${req.file.filename}`;
    res.json({ mediaUrl: fileUrl });
  });
});

module.exports = router;


