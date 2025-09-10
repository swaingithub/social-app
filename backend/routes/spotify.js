const express = require('express');
const router = express.Router();
const axios = require('axios');
require('dotenv').config();

const getSpotifyToken = async () => {
    const credentials = Buffer.from(`${process.env.SPOTIFY_CLIENT_ID}:${process.env.SPOTIFY_CLIENT_SECRET}`).toString('base64');

    try {
        const response = await axios({
            url: 'https://accounts.spotify.com/api/token',
            method: 'post',
            params: {
                grant_type: 'client_credentials'
            },
            headers: {
                'Authorization': `Basic ${credentials}`,
                'Content-Type': 'application/x-www-form-urlencoded'
            }
        });
        return response.data.access_token;
    } catch (error) {
        console.error('Error getting Spotify token:', error.response ? error.response.data : error.message);
        throw new Error('Failed to authenticate with Spotify');
    }
};

router.get('/search', async (req, res) => {
    const { q } = req.query;

    if (!q) {
        return res.status(400).json({ message: 'Search query is required' });
    }

    try {
        const token = await getSpotifyToken();

        const response = await axios.get('https://api.spotify.com/v1/search', {
            headers: {
                'Authorization': `Bearer ${token}`
            },
            params: {
                q,
                type: 'track',
                limit: 50
            }
        });

        const tracks = response.data.tracks.items
            .filter(track => track.preview_url)
            .map(track => ({
                id: track.id,
                title: track.name,
                artist: track.artists.map(artist => artist.name).join(', '),
                albumArt: track.album.images.length > 0 ? track.album.images[0].url : '',
                previewUrl: track.preview_url
            }));

        res.json(tracks);
    } catch (error) {
        console.error('Error searching Spotify:', error.response ? error.response.data : error.message);
        res.status(500).json({ message: 'Failed to search for music on Spotify' });
    }
});

router.get('/trending', async (req, res) => {
    try {
        const token = await getSpotifyToken();
        const playlistId = '37i9dQZEVXbMDoHDwVN2tF'; // Global Top 50 playlist ID

        const response = await axios.get(`https://api.spotify.com/v1/playlists/${playlistId}/tracks`, {
            headers: {
                'Authorization': `Bearer ${token}`
            },
            params: {
                limit: 100
            }
        });

        const tracks = response.data.items
            .map(item => item.track)
            .filter(track => track && track.preview_url)
            .map(track => ({
                id: track.id,
                title: track.name,
                artist: track.artists.map(artist => artist.name).join(', '),
                albumArt: track.album.images.length > 0 ? track.album.images[0].url : '',
                previewUrl: track.preview_url
            }));

        res.json(tracks);
    } catch (error) {
        console.error('Error fetching trending music from Spotify:', error.response ? error.response.data : error.message);
        res.status(500).json({ message: 'Failed to fetch trending music from Spotify' });
    }
});

module.exports = router;
