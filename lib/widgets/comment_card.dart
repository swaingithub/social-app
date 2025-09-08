import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/models/comment.dart';

class CommentCard extends StatefulWidget {
  final Comment comment;
  final String postId;
  const CommentCard({super.key, required this.comment, required this.postId});

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp.toDate());

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }

  Future<void> _likeComment() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final commentRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(widget.postId)
        .collection('comments')
        .doc(widget.comment.id);

    final isLiked = widget.comment.likes.contains(currentUser.uid);

    if (isLiked) {
      await commentRef.update({
        'likes': FieldValue.arrayRemove([currentUser.uid])
      });
    } else {
      await commentRef.update({
        'likes': FieldValue.arrayUnion([currentUser.uid])
      });
    }
  }

  String _getAuthorUsername() {
    final email = widget.comment.author;
    return email.split('@').first;
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isLiked = currentUser != null && widget.comment.likes.contains(currentUser.uid);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: DefaultTextStyle.of(context).style,
                    children: [
                      TextSpan(
                        text: '${_getAuthorUsername()} ',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      TextSpan(
                        text: widget.comment.content,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      _formatTimestamp(widget.comment.timestamp),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${widget.comment.likes.length} likes',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, size: 16),
            onPressed: _likeComment,
            color: isLiked ? Colors.red : null,
          ),
        ],
      ),
    );
  }
}
