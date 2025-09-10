import 'package:jivvi/models/post.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String? profileImageUrl;
  final String? coverImageUrl;
  final String? bio;
  final int followerCount;
  final int followingCount;
  final List<Post>? posts;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profileImageUrl,
    this.coverImageUrl,
    this.bio,
    required this.followerCount,
    required this.followingCount,
    this.posts,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      username: json['username'],
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
      coverImageUrl: json['coverImageUrl'],
      bio: json['bio'],
      followerCount: json['followerCount'] ?? json['followers']?.length ?? 0,
      followingCount: json['followingCount'] ?? json['following']?.length ?? 0,
      posts: json['posts'] != null ? (json['posts'] as List).map((i) => Post.fromJson(i)).toList() : null,
    );
  }
}
