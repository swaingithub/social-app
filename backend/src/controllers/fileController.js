const path = require('path');
const fs = require('fs');

// Upload file
const uploadFile = (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, msg: 'No file uploaded' });
    }

    // Construct the URL to access the file
    const fileUrl = `/uploads/${req.file.filename}`;
    
    res.status(200).json({
      success: true,
      msg: 'File uploaded successfully',
      filePath: fileUrl,
      fileName: req.file.filename
    });
  } catch (err) {
    console.error('Error uploading file:', err);
    res.status(500).json({ success: false, msg: 'Server error during file upload' });
  }
};

// Delete file
const deleteFile = (req, res) => {
  try {
    const { filename } = req.params;
    const filePath = path.join(__dirname, `../../uploads/${filename}`);
    
    if (fs.existsSync(filePath)) {
      fs.unlinkSync(filePath);
      return res.json({ success: true, msg: 'File deleted successfully' });
    }
    
    res.status(404).json({ success: false, msg: 'File not found' });
  } catch (err) {
    console.error('Error deleting file:', err);
    res.status(500).json({ success: false, msg: 'Server error during file deletion' });
  }
};

module.exports = {
  uploadFile,
  deleteFile
};
