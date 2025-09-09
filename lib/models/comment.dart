import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/models/user.dart';

class Comment {
  final String id;
  final String postId;
  final User author;
  final String text;
  final Timestamp timestamp;

  Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.text,
    required this.timestamp,
  });
}
