require('dotenv').config();
const express = require('express');
const connectDB = require('./config/db');
const sequelize = require('./config/sequelize');
const userRoutes = require('./routes/userRoutes');
const postRoutes = require('./routes/postRoutes');
const feedRoutes = require('./routes/feedRoutes');
const spotifyRoutes = require('../routes/spotify'); // Added spotify routes
const newsRoutes = require('./routes/newsRoutes');

const app = express();

// Connect to MongoDB
connectDB();

// Connect to MySQL and sync models
sequelize.authenticate()
  .then(() => {
    console.log('MySQL Connected...');
    // Sync models with the database
    sequelize.sync({ alter: true })
      .then(() => console.log('Sequelize models synced with database.'))
      .catch(err => console.log('Error syncing models: ' + err));
  })
  .catch(err => console.log('Error: ' + err));

// Init Middleware
app.use(express.json({ extended: false }));

// Define Routes
app.use('/api/users', userRoutes);
app.use('/api/posts', postRoutes);
app.use('/api/feed', feedRoutes);
app.use('/api/spotify', spotifyRoutes); // Added spotify routes
app.use('/api/news', newsRoutes);

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => console.log(`Server started on port ${PORT}`));
