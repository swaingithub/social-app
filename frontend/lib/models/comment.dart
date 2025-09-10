
import 'package:jivvi/models/user.dart';

class Comment {
  final String id;
  final String postId;
  final User author;
  final String text;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.text,
    required this.timestamp,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'] ?? json['id'] ?? '',
      postId: json['post'] ?? '', // Assuming the API returns 'post' field for postId
      author: User.fromJson(json['author'] is String 
          ? {'_id': json['author']} // Handle case where author might just be an ID
          : (json['author'] as Map<String, dynamic>)),
      text: json['text'] ?? '',
      timestamp: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }
}
