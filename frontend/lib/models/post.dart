import 'package:jivvi/models/user.dart';

class Post {
  final String id;
  final String caption;
  final String imageUrl;
  final User author;
  final List<User> likes;
  final List<Comment> comments;
  final List<User> taggedUsers;
  final String? music;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.caption,
    required this.imageUrl,
    required this.author,
    required this.likes,
    required this.comments,
    required this.taggedUsers,
    this.music,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'].toString(),
      caption: json['caption'],
      imageUrl: json['imageUrl'],
      author: User.fromJson(json['author']),
      likes: (json['likers'] as List).map((i) => User.fromJson(i)).toList(),
      comments: (json['comments'] as List).map((i) => Comment.fromJson(i)).toList(),
      taggedUsers: (json['taggedUsers'] as List).map((i) => User.fromJson(i)).toList(),
      music: json['music'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}

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
      id: json['id'].toString(),
      text: json['text'],
      author: User.fromJson(json['author']),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
