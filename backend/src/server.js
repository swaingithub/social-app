const express = require('express');
const connectDB = require('./config/db');
const sequelize = require('./config/sequelize');
const userRoutes = require('./routes/userRoutes');
const postRoutes = require('./routes/postRoutes');

const app = express();

// Connect to MongoDB
connectDB();

// Connect to MySQL
sequelize.authenticate()
  .then(() => console.log('MySQL Connected...'))
  .catch(err => console.log('Error: ' + err));

// Init Middleware
app.use(express.json({ extended: false }));

// Define Routes
app.use('/api/users', userRoutes);
app.use('/api/posts', postRoutes);

const PORT = process.env.PORT || 5000;

app.listen(PORT, () => console.log(`Server started on port ${PORT}`));
