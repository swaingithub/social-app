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
    final media = (json['mediaUrl'] ?? json['imageUrl'] ?? '').toString();
    final authorData = json['author'];
    final author = authorData is Map<String, dynamic>
        ? User.fromJson(authorData)
        : User.fromJson({'_id': authorData?.toString() ?? '', 'username': 'Unknown'});
    final likesList = (json['likes'] is List)
        ? List<String>.from((json['likes'] as List).map((e) => e.toString()))
        : <String>[];
    final commentsList = (json['comments'] is List)
        ? (json['comments'] as List).map((c) => Comment.fromJson(c)).toList()
        : <Comment>[];

    return Post(
      id: json['_id']?.toString() ?? '',
      mediaUrl: media,
      caption: json['caption']?.toString() ?? '',
      author: author,
      likes: likesList,
      comments: commentsList,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
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
