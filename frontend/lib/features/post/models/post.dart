import 'package:jivvi/features/auth/models/user.dart';
import 'package:jivvi/features/post/models/comment.dart';

class Post {
  final String id;
  final String imageUrl;
  final String caption;
  final User author;
  final List<String> likes;
  final List<Comment> comments;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.imageUrl,
    required this.caption,
    required this.author,
    required this.likes,
    required this.comments,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'],
      imageUrl: json['imageUrl'],
      caption: json['caption'],
      author: User.fromJson(json['author']),
      likes: List<String>.from(json['likes']),
      comments: (json['comments'] as List)
          .map((comment) => Comment.fromJson(comment))
          .toList(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'imageUrl': imageUrl,
      'caption': caption,
      'author': author.toJson(),
      'likes': likes,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
