const Post = require('../models/post');
const Comment = require('../models/comment');
const User = require('../models/user');

exports.createPost = async (req, res) => {
  const { caption, imageUrl, taggedUsers, music } = req.body;

  try {
    const newPost = await Post.create({
      caption,
      imageUrl,
      authorId: req.user.id,
      music,
    });

    if (taggedUsers && taggedUsers.length > 0) {
      await newPost.addTaggedUsers(taggedUsers);
    }

    res.json(newPost);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.getPosts = async (req, res) => {
  try {
    const posts = await Post.findAll({ include: [User, Comment] });
    res.json(posts);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.getPostById = async (req, res) => {
  try {
    const post = await Post.findByPk(req.params.id, { include: [User, Comment] });

    if (!post) {
      return res.status(404).json({ msg: 'Post not found' });
    }

    res.json(post);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.deletePost = async (req, res) => {
  try {
    const post = await Post.findByPk(req.params.id);

    if (!post) {
      return res.status(404).json({ msg: 'Post not found' });
    }

    if (post.authorId !== req.user.id) {
      return res.status(401).json({ msg: 'User not authorized' });
    }

    await post.destroy();

    res.json({ msg: 'Post removed' });
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.likePost = async (req, res) => {
  try {
    const post = await Post.findByPk(req.params.id);
    if (!post) return res.status(404).json({ msg: 'Post not found' });

    // Check if already liked
    const isLiked = await post.hasLikedBy(req.user.id);
    if (isLiked) {
      return res.status(400).json({ msg: 'Post already liked' });
    }

    // Add like
    await post.addLikedBy(req.user.id);
    
    // Reload the post with updated likes
    const updatedPost = await Post.findByPk(req.params.id, {
      include: [
        { model: User, as: 'likedBy', attributes: ['id', 'username', 'profileImageUrl'] },
        { model: User, as: 'author', attributes: ['id', 'username', 'profileImageUrl'] },
        { model: Comment, include: [{ model: User, attributes: ['id', 'username', 'profileImageUrl'] }] }
      ]
    });

    res.json(updatedPost);
  } catch (err) {
    console.error('Like error:', err);
    res.status(500).send('Server Error');
  }
};

exports.unlikePost = async (req, res) => {
  try {
    const post = await Post.findByPk(req.params.id);
    if (!post) return res.status(404).json({ msg: 'Post not found' });

    // Check if not liked
    const isLiked = await post.hasLikedBy(req.user.id);
    if (!isLiked) {
      return res.status(400).json({ msg: 'Post not liked yet' });
    }

    // Remove like
    await post.removeLikedBy(req.user.id);
    
    // Reload the post with updated likes
    const updatedPost = await Post.findByPk(req.params.id, {
      include: [
        { model: User, as: 'likedBy', attributes: ['id', 'username', 'profileImageUrl'] },
        { model: User, as: 'author', attributes: ['id', 'username', 'profileImageUrl'] },
        { model: Comment, include: [{ model: User, attributes: ['id', 'username', 'profileImageUrl'] }] }
      ]
    });

    res.json(updatedPost);
  } catch (err) {
    console.error('Unlike error:', err);
    res.status(500).send('Server Error');
  }
};

exports.addComment = async (req, res) => {
  try {
    const post = await Post.findByPk(req.params.id);
    const newComment = await Comment.create({
      text: req.body.text,
      authorId: req.user.id,
      postId: post.id,
    });
    res.json(newComment);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.getPostsByUser = async (req, res) => {
  try {
    const posts = await Post.findAll({ where: { authorId: req.params.userId } });
    res.json(posts);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
