const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');
const User = require('./user');

const Post = sequelize.define('Post', {
  id: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  caption: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  imageUrl: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  music: {
    type: DataTypes.STRING,
  },
  authorId: {
    type: DataTypes.INTEGER,
    allowNull: false,
    references: {
      model: 'Users',
      key: 'id',
    },
    onDelete: 'CASCADE',
  },
  createdAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
  updatedAt: {
    type: DataTypes.DATE,
    defaultValue: DataTypes.NOW,
  },
});

// Author relationship
Post.belongsTo(User, {
  foreignKey: 'authorId',
  as: 'author',
  onDelete: 'CASCADE'
});

// Many-to-many relationship for likes
Post.belongsToMany(User, {
  through: 'PostLikes',
  as: 'likedBy',
  foreignKey: 'postId',
  otherKey: 'userId',
  timestamps: false,
});

// User's liked posts
User.belongsToMany(Post, {
  through: 'PostLikes',
  as: 'likedPosts',
  foreignKey: 'userId',
  otherKey: 'postId',
  timestamps: false,
});

module.exports = Post;
