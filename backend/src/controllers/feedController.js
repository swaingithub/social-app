
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
    // Mix followed users with recent trending posts
    const baseQuery = { $or: [
      { author: { $in: followingIds } },
      { createdAt: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) } }
    ]};

    const posts = await Post.find(baseQuery)
      .sort({ likeCount: -1, createdAt: -1 })
      .limit(50)
      .populate('author', 'username profileImageUrl fullName')
      .populate('likes', 'username profileImageUrl')
      .populate({
        path: 'comments',
        populate: {
          path: 'author',
          select: 'username profileImageUrl'
        },
        options: { sort: { createdAt: -1 } }
      });

    res.json({
      success: true,
      count: posts.length,
      data: posts.map(p => ({
        _id: p._id,
        mediaUrl: p.imageUrl,
        caption: p.caption,
        author: p.author,
        likes: p.likes,
        createdAt: p.createdAt,
        likeCount: p.likeCount,
        commentCount: p.commentCount,
      }))
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
