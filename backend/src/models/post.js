const mongoose = require('mongoose');

const postSchema = new mongoose.Schema({
  imageUrl: {
    type: String,
    required: true,
  },
  caption: {
    type: String,
    default: '',
  },
  author: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  likes: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  }],
  comments: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Comment',
  }],
}, {
  timestamps: true,
});

module.exports = mongoose.model('Post', postSchema);
