import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/models/comment.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/user.dart';

class ApiService {
  // Simulate a network delay
  Future<void> _delay() => Future.delayed(const Duration(seconds: 2));

  Future<List<Post>> getFeed() async {
    await _delay();
    return List.generate(
      10,
      (index) => Post(
        id: 'post_$index',
        author: 'user_$index',
        imageUrl: 'https://picsum.photos/seed/${Random().nextInt(1000)}/800/600',
        caption: 'This is a caption for post #$index',
        likes: List.generate(Random().nextInt(10), (i) => 'like_$i'),
        commentCount: Random().nextInt(100),
        timestamp: Timestamp.fromDate(
          DateTime.now().subtract(Duration(minutes: index * 5)),
        ),
      ),
    );
  }

  Future<List<Comment>> getComments(String postId) async {
    await _delay();
    return List.generate(
      15,
      (index) => Comment(
        id: 'comment_$index',
        postId: postId,
        author: User(
          id: 'user_$index',
          username: 'user$index',
          email: 'user$index@example.com',
          bio: 'This is a bio for user$index.',
          profileImageUrl: 'https://i.pravatar.cc/150?u=user$index',
        ),
        text: 'This is a comment for post #$postId, comment #$index',
        timestamp: Timestamp.fromDate(
          DateTime.now().subtract(Duration(minutes: index * 2)),
        ),
      ),
    );
  }
}
