import 'package:flutter/material.dart';
import 'package:jivvi/core/services/api_service.dart';

class ConversationModel {
  final String id;
  final List<Map<String, dynamic>> participants;
  final String lastMessage;

  ConversationModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
  });

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['_id']?.toString() ?? '',
      participants: List<Map<String, dynamic>>.from(
        (json['participants'] ?? []).map((p) => {
          '_id': p['_id']?.toString(),
          'username': p['username'],
          'profileImageUrl': p['profileImageUrl'],
        }),
      ),
      lastMessage: json['lastMessage']?.toString() ?? '',
    );
  }
}

class MessageModel {
  final String id;
  final String text;
  final String mediaUrl;
  final Map<String, dynamic> sender;

  MessageModel({
    required this.id,
    required this.text,
    required this.mediaUrl,
    required this.sender,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['_id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      mediaUrl: json['mediaUrl']?.toString() ?? '',
      sender: {
        '_id': json['sender']?['_id']?.toString(),
        'username': json['sender']?['username'],
        'profileImageUrl': json['sender']?['profileImageUrl'],
      },
    );
  }
}

class ChatProvider with ChangeNotifier {
  final ApiService _api = ApiService();

  bool _loading = false;
  List<ConversationModel> _conversations = [];
  List<MessageModel> _messages = [];

  bool get loading => _loading;
  List<ConversationModel> get conversations => _conversations;
  List<MessageModel> get messages => _messages;

  Future<void> loadConversations() async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.getConversations();
      _conversations = List<Map<String, dynamic>>.from(data)
          .map((e) => ConversationModel.fromJson(e))
          .toList();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> openOrCreateConversation(String userId) async {
    final data = await _api.createOrGetConversation(userId);
    return data['_id']?.toString();
  }

  Future<void> loadMessages(String conversationId) async {
    _loading = true;
    notifyListeners();
    try {
      final data = await _api.getMessages(conversationId);
      _messages = List<Map<String, dynamic>>.from(data)
          .map((e) => MessageModel.fromJson(e))
          .toList();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String conversationId, {String text = '', String mediaUrl = ''}) async {
    final data = await _api.sendChatMessage(conversationId, text: text, mediaUrl: mediaUrl);
    _messages.add(MessageModel.fromJson(data));
    notifyListeners();
  }
}


