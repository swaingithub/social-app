import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/models/comment.dart';
import 'package:social_media_app/widgets/comment_card.dart';

class CommentsScreen extends StatefulWidget {
  final String postId;
  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final TextEditingController _commentController = TextEditingController();
  bool _isPosting = false;

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    setState(() {
      _isPosting = true;
    });

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to add a comment.')),
      );
      setState(() {
        _isPosting = false;
      });
      return;
    }

    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.postId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final postSnapshot = await transaction.get(postRef);
      if (!postSnapshot.exists) {
        throw Exception("Post does not exist!");
      }

      final newCommentCount = (postSnapshot.data()!['commentCount'] ?? 0) + 1;

      transaction.update(postRef, {'commentCount': newCommentCount});

      final newCommentRef = postRef.collection('comments').doc();
      transaction.set(newCommentRef, {
        'author': currentUser.email,
        'content': _commentController.text,
        'timestamp': Timestamp.now(),
        'likes': [],
      });
    });

    _commentController.clear();

    setState(() {
      _isPosting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isGuest = currentUser == null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .collection('comments')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(child: Text('An error occurred.'));
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No comments yet.'));
                }

                final comments = snapshot.data!.docs
                    .map((doc) => Comment.fromMap(doc.data() as Map<String, dynamic>, doc.id))
                    .toList();

                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return CommentCard(comment: comment, postId: widget.postId);
                  },
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: isGuest ? 'Log in to add a comment' : 'Add a comment...',
                      border: InputBorder.none,
                    ),
                    enabled: !isGuest,
                  ),
                ),
                if (_isPosting)
                  const CircularProgressIndicator()
                else
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: isGuest ? null : _addComment,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
