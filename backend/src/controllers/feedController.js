
const Feed = require('../models/feed');
const Post = require('../models/post');
const Relationship = require('../models/relationship');

exports.getFeed = async (req, res) => {
  try {
    const following = await Relationship.findAll({ where: { followerId: req.user.id } });
    const followingIds = following.map(item => item.followingId);

    const posts = await Post.find({ author: { $in: followingIds } }).sort({ createdAt: -1 });

    let feed = await Feed.findOne({ user: req.user.id });
    if (!feed) {
      feed = await Feed.create({ user: req.user.id });
    }

    feed.posts = posts.map(post => post.id);
    await feed.save();

    res.json(posts);
  } catch (err) {
    console.error(err.message);
    res.status(500).send('Server error');
  }
};
