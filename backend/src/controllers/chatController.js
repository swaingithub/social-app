const Conversation = require('../models/conversation');
const Message = require('../models/message');

exports.listConversations = async (req, res) => {
  try {
    const conversations = await Conversation.find({ participants: req.user.id })
      .sort({ updatedAt: -1 })
      .populate('participants', 'username profileImageUrl');
    res.json({ success: true, data: conversations });
  } catch (err) {
    console.error('listConversations error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
};

exports.getOrCreateConversation = async (req, res) => {
  try {
    const peerId = req.params.userId;
    if (!peerId) return res.status(400).json({ msg: 'Missing userId' });

    let conversation = await Conversation.findOne({
      participants: { $all: [req.user.id, peerId] },
    });

    if (!conversation) {
      conversation = await Conversation.create({
        participants: [req.user.id, peerId],
      });
    }

    const populated = await Conversation.findById(conversation._id)
      .populate('participants', 'username profileImageUrl');
    res.json({ success: true, data: populated });
  } catch (err) {
    console.error('getOrCreateConversation error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
};

exports.listMessages = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const messages = await Message.find({ conversation: conversationId })
      .sort({ createdAt: -1 })
      .limit(50)
      .populate('sender', 'username profileImageUrl');
    res.json({ success: true, data: messages.reverse() });
  } catch (err) {
    console.error('listMessages error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
};

exports.sendMessage = async (req, res) => {
  try {
    const { conversationId } = req.params;
    const { text, mediaUrl } = req.body;
    const message = await Message.create({
      conversation: conversationId,
      sender: req.user.id,
      text: text || '',
      mediaUrl: mediaUrl || '',
    });

    await Conversation.findByIdAndUpdate(conversationId, {
      lastMessage: text || (mediaUrl ? 'Media' : ''),
      updatedAt: new Date(),
    });

    const populated = await Message.findById(message._id).populate('sender', 'username profileImageUrl');
    res.status(201).json({ success: true, data: populated });
  } catch (err) {
    console.error('sendMessage error:', err);
    res.status(500).json({ msg: 'Server error' });
  }
};


