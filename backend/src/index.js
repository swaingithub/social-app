const express = require('express');
const sequelize = require('./config/sequelize');
const userRoutes = require('./routes/userRoutes');
const postRoutes = require('./routes/postRoutes');

const User = require('./models/user');
const Post = require('./models/post');
const Comment = require('./models/comment');
const Relationship = require('./models/relationship');

const app = express();

app.use(express.json());

// Define relationships
User.hasMany(Post, { foreignKey: 'authorId' });
Post.belongsTo(User, { as: 'author', foreignKey: 'authorId' });

User.hasMany(Comment, { foreignKey: 'authorId' });
Comment.belongsTo(User, { as: 'author', foreignKey: 'authorId' });

Post.hasMany(Comment, { foreignKey: 'postId' });
Comment.belongsTo(Post, { foreignKey: 'postId' });

User.belongsToMany(User, { as: 'followers', through: Relationship, foreignKey: 'followingId' });
User.belongsToMany(User, { as: 'following', through: Relationship, foreignKey: 'followerId' });

Post.belongsToMany(User, { as: 'likers', through: 'Likes', foreignKey: 'postId' });
User.belongsToMany(Post, { as: 'likedPosts', through: 'Likes', foreignKey: 'userId' });

Post.belongsToMany(User, { as: 'taggedUsers', through: 'Tags', foreignKey: 'postId' });
User.belongsToMany(Post, { as: 'taggedPosts', through: 'Tags', foreignKey: 'userId' });

app.use('/api/users', userRoutes);
app.use('/api/posts', postRoutes);

const PORT = process.env.PORT || 5000;

sequelize.sync().then(() => {
  app.listen(PORT, () => console.log(`Server started on port ${PORT}`));
});
