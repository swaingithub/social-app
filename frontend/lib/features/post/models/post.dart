import 'package:jivvi/features/auth/models/user.dart';
import 'package:jivvi/features/post/models/comment.dart';

class Post {
  final String id;
  final String mediaUrl;
  final String caption;
  final User author;
  final List<String> likes;
  final List<Comment> comments;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.mediaUrl,
    required this.caption,
    required this.author,
    required this.likes,
    required this.comments,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'],
      mediaUrl: json['mediaUrl'],
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
      'mediaUrl': mediaUrl,
      'caption': caption,
      'author': author.toJson(),
      'likes': likes,
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool isLikedBy(String userId) {
    return likes.contains(userId);
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
