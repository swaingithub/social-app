const mongoose = require('mongoose');

const relationshipSchema = new mongoose.Schema({
  follower: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  following: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  status: {
    type: String,
    enum: ['pending', 'accepted', 'rejected'],
    default: 'pending'
  },
  createdAt: {
    type: Date,
    default: Date.now
  }
}, {
  timestamps: true
});

// Create a compound index to ensure unique follower-following pairs
relationshipSchema.index({ follower: 1, following: 1 }, { unique: true });

// Create a text index for search functionality
relationshipSchema.index({ status: 'text' });

// Static method to check if a relationship exists between two users
relationshipSchema.statics.relationshipExists = async function(followerId, followingId) {
  const count = await this.countDocuments({
    follower: followerId,
    following: followingId
  });
  return count > 0;
};

// Method to get all followers of a user
relationshipSchema.statics.getFollowers = function(userId) {
  return this.find({ following: userId, status: 'accepted' })
    .populate('follower', 'username profilePicture fullName')
    .select('follower createdAt');
};

// Method to get all users a user is following
relationshipSchema.statics.getFollowing = function(userId) {
  return this.find({ follower: userId, status: 'accepted' })
    .populate('following', 'username profilePicture fullName')
    .select('following createdAt');
};

// Method to get pending follow requests
relationshipSchema.statics.getPendingRequests = function(userId) {
  return this.find({ following: userId, status: 'pending' })
    .populate('follower', 'username profilePicture fullName')
    .select('follower createdAt');
};

const Relationship = mongoose.model('Relationship', relationshipSchema);

module.exports = Relationship;
