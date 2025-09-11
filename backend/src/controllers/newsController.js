const axios = require('axios');

const getNews = async (req, res) => {
  try {
    if (!process.env.NEWS_API_KEY) {
      return res.status(200).json([]);
    }
    const response = await axios.get(
      `https://newsapi.org/v2/top-headlines?country=us&apiKey=${process.env.NEWS_API_KEY}`
    );
    res.json(response.data.articles);
  } catch (error) {
    console.error(error.message);
    res.status(500).send('Server Error');
  }
};

module.exports = { getNews };
