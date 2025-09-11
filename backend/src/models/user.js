const mongoose = require('mongoose');

const userSchema = new mongoose.Schema({
  username: {
    type: String,
    required: [true, 'Username is required'],
    unique: true,
    trim: true,
    minlength: [3, 'Username must be at least 3 characters long'],
    maxlength: [30, 'Username cannot be longer than 30 characters'],
    match: [/^[a-zA-Z0-9_]+$/, 'Username can only contain letters, numbers, and underscores']
  },
  email: {
    type: String,
    required: [true, 'Email is required'],
    unique: true,
    trim: true,
    lowercase: true,
    match: [/^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$/, 'Please enter a valid email address']
  },
  password: {
    type: String,
    required: [true, 'Password is required'],
    minlength: [6, 'Password must be at least 6 characters long'],
    select: false
  },
  profileImageUrl: {
    type: String,
    default: 'https://res.cloudinary.com/demo/image/upload/v1621432348/default-avatar.png'
  },
  bio: {
    type: String,
    maxlength: [150, 'Bio cannot be longer than 150 characters'],
    default: ''
  },
  fullName: {
    type: String,
    trim: true,
    default: ''
  },
  website: {
    type: String,
    trim: true,
    default: ''
  },
  location: {
    type: String,
    trim: true,
    default: ''
  },
  followers: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: []
  }],
  following: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: []
  }],
  isPrivate: {
    type: Boolean,
    default: false
  },
  isVerified: {
    type: Boolean,
    default: false
  },
  lastActive: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true,
  toJSON: {
    virtuals: true,
    transform: function(doc, ret) {
      delete ret.password;
      delete ret.__v;
      return ret;
    }
  },
  toObject: {
    virtuals: true,
    transform: function(doc, ret) {
      delete ret.password;
      delete ret.__v;
      return ret;
    }
  }
});

// Virtual for follower/following counts (tolerant to missing arrays)
userSchema.virtual('followerCount').get(function() {
  const list = Array.isArray(this.followers) ? this.followers : [];
  return list.length;
});

userSchema.virtual('followingCount').get(function() {
  const list = Array.isArray(this.following) ? this.following : [];
  return list.length;
});

// Method to check if a user follows another user
userSchema.methods.isFollowing = function(userId) {
  return this.following.some(id => id.toString() === userId.toString());
};

// Method to check if a user is followed by another user
userSchema.methods.isFollowedBy = function(userId) {
  return this.followers.some(id => id.toString() === userId.toString());
};

// Method to update last active timestamp
userSchema.methods.updateLastActive = function() {
  this.lastActive = Date.now();
  return this.save();
};

module.exports = mongoose.model('User', userSchema);
