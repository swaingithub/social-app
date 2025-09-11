require('dotenv').config();
const express = require('express');
const connectDB = require('./config/db');
const cors = require('cors');
const userRoutes = require('./routes/userRoutes');
const postRoutes = require('./routes/postRoutes');
const feedRoutes = require('./routes/feedRoutes');
const spotifyRoutes = require('../routes/spotify');
const newsRoutes = require('./routes/newsRoutes');
const uploadRoutes = require('./routes/uploadRoutes');
const chatRoutes = require('./routes/chatRoutes');
const { seedBotAndContent } = require('./utils/seed');

const app = express();

// Connect to MongoDB only
connectDB();

// Init Middleware
app.use(cors());
app.use(express.json({ extended: false }));

// Define Routes
app.use('/api/users', userRoutes);
app.use('/api/posts', postRoutes);
app.use('/api/feed', feedRoutes);
app.use('/api/spotify', spotifyRoutes);
app.use('/api/news', newsRoutes);
app.use('/api/files', uploadRoutes);
app.use('/api/chat', chatRoutes);

// Serve uploaded files statically
const path = require('path');
app.use('/uploads', express.static(path.join(__dirname, '../uploads')));

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => console.log(`Server started on port ${PORT}`));

// Seed demo bot and content (non-blocking)
(async () => {
  if (process.env.SEED_BOT !== 'false') {
    const result = await seedBotAndContent();
    if (result.ok) {
      console.log('Bot seed ready');
    }
  }
})();
