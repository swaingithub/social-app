import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/models/comment.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/models/user.dart';

class ApiService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  Future<void> toggleLike(String postId, String userId) {
    final postRef = _firestore.collection('posts').doc(postId);

    return _firestore.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);

      if (!postSnapshot.exists) {
        throw Exception("Post does not exist!");
      }

      final List<String> likes = List<String>.from(postSnapshot.data()!['likes'] ?? []);

      if (likes.contains(userId)) {
        transaction.update(postRef, {
          'likes': FieldValue.arrayRemove([userId])
        });
      } else {
        transaction.update(postRef, {
          'likes': FieldValue.arrayUnion([userId])
        });
      }
    });
  }

  Future<User> getUser(String userId) async {
    final userDoc = await _firestore.collection('users').doc(userId).get();
    return User.fromMap(userDoc.data()!);
  }

  Future<Comment> addComment(String postId, String text, String userId) async {
    final user = await getUser(userId);
    final commentRef = _firestore.collection('posts').doc(postId).collection('comments').doc();

    final newComment = Comment(
      id: commentRef.id,
      postId: postId,
      author: user,
      text: text,
      timestamp: Timestamp.now(),
    );

    await commentRef.set({
      'id': newComment.id,
      'postId': newComment.postId,
      'author': {
        'id': user.id,
        'username': user.username,
        'email': user.email,
        'bio': user.bio,
        'profileImageUrl': user.profileImageUrl,
      },
      'text': newComment.text,
      'timestamp': newComment.timestamp,
    });

    return newComment;
  }
}
