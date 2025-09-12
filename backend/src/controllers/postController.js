const Post = require('../models/post');
const Comment = require('../models/comment');
const User = require('../models/user');

exports.createPost = async (req, res) => {
  const { caption, imageUrl, mediaUrl, music } = req.body;

  try {
    const text = caption || '';
    const tags = (text.match(/#\w+/g) || []).map(t => t.slice(1).toLowerCase());
    const newPost = await Post.create({
      caption: text,
      imageUrl: imageUrl || mediaUrl,
      author: req.user.id,
      music,
      hashtags: tags
    });

    return res.status(201).json({ success: true, data: newPost });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.getPosts = async (req, res) => {
  try {
    const posts = await Post.find()
      .sort({ createdAt: -1 })
      .populate('author', 'username profileImageUrl')
      .populate('likes', 'username profileImageUrl')
      .populate({
        path: 'comments',
        options: { sort: { createdAt: -1 } },
        populate: { path: 'author', select: 'username profileImageUrl' }
      });
    res.json(posts.map(p => {
      const mediaUrl = p.imageUrl || p.get && p.get('mediaUrl') || '';
      const authorRef = p.author || p.get && p.get('author') || p.get && p.get('authorId');
      return {
        _id: p._id,
        mediaUrl,
        caption: p.caption || p.get && p.get('caption') || '',
        author: authorRef,
        likes: Array.isArray(p.likes) ? p.likes : [],
        comments: Array.isArray(p.comments) ? p.comments : [],
        createdAt: p.createdAt,
      };
    }));
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.getPostById = async (req, res) => {
  try {
    const post = await Post.findById(req.params.id)
      .populate('author', 'username profileImageUrl')
      .populate('likes', 'username profileImageUrl')
      .populate({
        path: 'comments',
        options: { sort: { createdAt: -1 } },
        populate: { path: 'author', select: 'username profileImageUrl' }
      });

    if (!post) {
      return res.status(404).json({ msg: 'Post not found' });
    }

    const mediaUrl = post.imageUrl || post.get && post.get('mediaUrl') || '';
    const authorRef = post.author || post.get && post.get('author') || post.get && post.get('authorId');
    res.json({
      _id: post._id,
      mediaUrl,
      caption: post.caption || post.get && post.get('caption') || '',
      author: authorRef,
      likes: Array.isArray(post.likes) ? post.likes : [],
      comments: Array.isArray(post.comments) ? post.comments : [],
      createdAt: post.createdAt,
    });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.deletePost = async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);

    if (!post) {
      return res.status(404).json({ msg: 'Post not found' });
    }

    if (post.author.toString() !== req.user.id.toString()) {
      return res.status(401).json({ msg: 'User not authorized' });
    }

    await post.deleteOne();

    res.json({ msg: 'Post removed' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.likePost = async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    if (!post) return res.status(404).json({ msg: 'Post not found' });

    const alreadyLiked = post.likes.some(id => id.toString() === req.user.id.toString());
    if (alreadyLiked) {
      return res.status(400).json({ msg: 'Post already liked' });
    }

    post.likes.push(req.user.id);
    post.likeCount = (post.likeCount || 0) + 1;
    await post.save();

    const updatedPost = await Post.findById(req.params.id)
      .populate('author', 'username profileImageUrl')
      .populate('likes', 'username profileImageUrl')
      .populate({
        path: 'comments',
        options: { sort: { createdAt: -1 } },
        populate: { path: 'author', select: 'username profileImageUrl' }
      });

    res.json({ success: true, data: updatedPost });
  } catch (err) {
    console.error('Like error:', err);
    res.status(500).send('Server Error');
  }
};

exports.unlikePost = async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    if (!post) return res.status(404).json({ msg: 'Post not found' });

    const wasLiked = post.likes.some(id => id.toString() === req.user.id.toString());
    if (!wasLiked) {
      return res.status(400).json({ msg: 'Post not liked yet' });
    }

    post.likes = post.likes.filter(id => id.toString() !== req.user.id.toString());
    post.likeCount = Math.max(0, (post.likeCount || 0) - 1);
    await post.save();

    const updatedPost = await Post.findById(req.params.id)
      .populate('author', 'username profileImageUrl')
      .populate('likes', 'username profileImageUrl')
      .populate({
        path: 'comments',
        options: { sort: { createdAt: -1 } },
        populate: { path: 'author', select: 'username profileImageUrl' }
      });

    res.json({ success: true, data: updatedPost });
  } catch (err) {
    console.error('Unlike error:', err);
    res.status(500).send('Server Error');
  }
};

exports.addComment = async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    if (!post) return res.status(404).json({ msg: 'Post not found' });

    const newComment = await Comment.create({
      text: req.body.text,
      author: req.user.id,
      post: post._id
    });

    post.commentCount = (post.commentCount || 0) + 1;
    await post.save();

    const populated = await Comment.findById(newComment._id)
      .populate('author', 'username profileImageUrl');

    res.status(201).json({ success: true, data: populated });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.getPostsByUser = async (req, res) => {
  try {
    const posts = await Post.find({ author: req.params.userId })
      .sort({ createdAt: -1 })
      .populate('author', 'username profileImageUrl');
    res.json({ success: true, data: posts });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

// Related posts by hashtags and same author as fallback
exports.getRelatedPosts = async (req, res) => {
  try {
    const seed = await Post.findById(req.params.id);
    if (!seed) return res.status(404).json({ msg: 'Post not found' });

    const tags = seed.hashtags || [];
    const related = await Post.find({
      _id: { $ne: seed._id },
      $or: [
        { hashtags: { $in: tags } },
        { author: seed.author }
      ]
    })
      .sort({ likeCount: -1, createdAt: -1 })
      .limit(20)
      .populate('author', 'username profileImageUrl');

    res.json({ success: true, data: related.map(p => ({
      _id: p._id,
      mediaUrl: p.imageUrl,
      caption: p.caption,
      author: p.author,
      createdAt: p.createdAt,
      likeCount: p.likeCount,
    })) });
  } catch (err) {
    console.error('getRelatedPosts error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
};

// Fetch comments for a post
exports.getComments = async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    if (!post) return res.status(404).json({ msg: 'Post not found' });

    const comments = await Comment.find({ post: post._id })
      .sort({ createdAt: -1 })
      .populate('author', 'username profileImageUrl');

    res.json({ success: true, data: comments });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
