
const Post = require('../models/post');
const Relationship = require('../models/relationship');
const User = require('../models/user');

// @desc    Get user's feed
// @route   GET /api/feed
// @access  Private
exports.getFeed = async (req, res) => {
  try {
    // Get all users that the current user is following
    const relationships = await Relationship.find({ 
      follower: req.user.id,
      status: 'accepted' 
    }).select('following');

    // Extract the user IDs of the people being followed
    const followingIds = relationships.map(rel => rel.following);
    
    // Add current user's ID to see their own posts in the feed
    followingIds.push(req.user.id);

    // Get posts from followed users, sorted by creation date (newest first)
    const posts = await Post.find({ author: { $in: followingIds } })
      .sort({ createdAt: -1 })
      .populate('author', 'username profilePicture fullName')
      .populate('likes', 'username profilePicture')
      .populate({
        path: 'comments',
        populate: {
          path: 'author',
          select: 'username profilePicture'
        },
        options: { sort: { createdAt: -1 } }
      });

    res.json({
      success: true,
      count: posts.length,
      data: posts
    });
  } catch (err) {
    console.error('Error in getFeed:', err);
    res.status(500).json({
      success: false,
      error: 'Server error',
      message: err.message
    });
  }
};
