import 'package:jivvi/features/auth/models/user.dart';

class Comment {
  final String id;
  final String text;
  final User author;
  final DateTime createdAt;

  Comment({
    required this.id,
    required this.text,
    required this.author,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id'],
      text: json['text'],
      author: User.fromJson(json['author']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'text': text,
      'author': author.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
