import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String id;
  final String author;
  final String caption;
  final Timestamp timestamp;
  final String? imageUrl;
  final List<String> likes;
  final int commentCount;
  final String? location;

  Post({
    required this.id,
    required this.author,
    required this.caption,
    required this.timestamp,
    this.imageUrl,
    this.likes = const [],
    this.commentCount = 0,
    this.location,
  });

  factory Post.fromMap(Map<String, dynamic> data, String documentId) {
    return Post(
      id: documentId,
      author: data['author'] ?? '',
      caption: data['caption'] ?? '',
      timestamp: data['timestamp'] ?? Timestamp.now(),
      imageUrl: data['imageUrl'],
      likes: List<String>.from(data['likes'] ?? []),
      commentCount: data['commentCount'] ?? 0,
      location: data['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'author': author,
      'caption': caption,
      'timestamp': timestamp,
      'imageUrl': imageUrl,
      'likes': likes,
      'commentCount': commentCount,
      'location': location,
    };
  }
}
