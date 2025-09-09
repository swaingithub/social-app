import 'dart:math';

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
        author: User(
          id: 'user_$index',
          username: 'user$index',
          email: 'user$index@example.com',
          bio: 'This is a bio for user$index.',
          profileImageUrl: 'https://i.pravatar.cc/150?u=user$index',
        ),
        imageUrl: 'https://picsum.photos/seed/${Random().nextInt(1000)}/800/600',
        caption: 'This is a caption for post #$index',
        likes: Random().nextInt(1000),
        commentCount: Random().nextInt(100),
        timestamp: DateTime.now().subtract(Duration(minutes: index * 5)),
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
        timestamp: DateTime.now().subtract(Duration(minutes: index * 2)),
      ),
    );
  }
}
