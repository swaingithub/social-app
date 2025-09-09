const Post = require('../models/post');

exports.createPost = async (req, res) => {
  const { caption, imageUrl } = req.body;

  try {
    const newPost = new Post({
      caption,
      imageUrl,
      author: req.user.id,
    });

    const post = await newPost.save();
    res.json(post);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};

exports.getPosts = async (req, res) => {
  try {
    const posts = await Post.find().sort({ createdAt: -1 });
    res.json(posts);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server Error');
  }
};
