import 'package:cloud_firestore/cloud_firestore.dart';

class Comment {
  final String id;
  final String author;
  final String content;
  final Timestamp timestamp;
  final List<String> likes;

  Comment({
    required this.id,
    required this.author,
    required this.content,
    required this.timestamp,
    this.likes = const [],
  });

  factory Comment.fromMap(Map<String, dynamic> data, String documentId) {
    return Comment(
      id: documentId,
      author: data['author'] ?? '',
      content: data['content'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      likes: List<String>.from(data['likes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'author': author,
      'content': content,
      'timestamp': timestamp,
      'likes': likes,
    };
  }
}
