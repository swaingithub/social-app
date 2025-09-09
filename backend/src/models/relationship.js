const { DataTypes } = require('sequelize');
const sequelize = require('../config/sequelize');

const Relationship = sequelize.define('Relationship', {
  followerId: {
    type: DataTypes.INTEGER,
    references: {
      model: 'Users',
      key: 'id',
    },
    allowNull: false,
  },
  followingId: {
    type: DataTypes.INTEGER,
    references: {
      model: 'Users',
      key: 'id',
    },
    allowNull: false,
  },
});

module.exports = Relationship;
