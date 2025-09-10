
import 'package:social_media_app/models/user.dart';

class Post {
  final String id;
  final User author;
  final String caption;
  final String imageUrl;
  final List<String> likes;
  final List<String> comments;
  final List<String> taggedUsers;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.author,
    required this.caption,
    required this.imageUrl,
    required this.likes,
    required this.comments,
    required this.taggedUsers,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] ?? '',
      author: User.fromJson(json['author'] ?? {}),
      caption: json['caption'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      likes: List<String>.from(json['likes'] ?? []),
      comments: List<String>.from(json['comments'] ?? []),
      taggedUsers: List<String>.from(json['taggedUsers'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}
