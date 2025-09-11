const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { listConversations, getOrCreateConversation, listMessages, sendMessage } = require('../controllers/chatController');

router.get('/conversations', auth, listConversations);
router.post('/conversations/:userId', auth, getOrCreateConversation);
router.get('/messages/:conversationId', auth, listMessages);
router.post('/messages/:conversationId', auth, sendMessage);

module.exports = router;


