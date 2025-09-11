const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const Post = sequelize.define('Post', {
  imageUrl: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  caption: {
    type: DataTypes.STRING,
    allowNull: true,
  },
  music: {
    type: DataTypes.STRING,
    allowNull: true,
  },
});

module.exports = Post;
