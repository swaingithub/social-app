import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:social_media_app/models/post.dart';

class PostCard extends StatefulWidget {
  final Post post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isHeartVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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

  String _getAuthorUsername() {
    final email = widget.post.author;
    return email.split('@').first;
  }

  Future<void> _likePost() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to like a post.')),
      );
      return;
    }

    final postRef = FirebaseFirestore.instance.collection('posts').doc(widget.post.id);

    final isLiked = widget.post.likes.contains(currentUser.uid);

    if (isLiked) {
      await postRef.update({
        'likes': FieldValue.arrayRemove([currentUser.uid])
      });
    } else {
      setState(() {
        _isHeartVisible = true;
        _animationController.forward(from: 0);
      });

      await postRef.update({
        'likes': FieldValue.arrayUnion([currentUser.uid])
      });

      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          setState(() {
            _isHeartVisible = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;
    final isLiked = currentUser != null && widget.post.likes.contains(currentUser.uid);

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(context),
          if (widget.post.imageUrl != null)
            GestureDetector(
              onDoubleTap: _likePost,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Image.network(
                    widget.post.imageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 400,
                  ),
                  if (_isHeartVisible)
                    FadeTransition(
                      opacity: _animation,
                      child: const Icon(Icons.favorite, color: Colors.white, size: 100),
                    ),
                ],
              ),
            ),
          _buildActionButtons(context, isLiked),
          _buildPostDetails(context),
        ],
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            child: Icon(Icons.person, size: 20),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getAuthorUsername(), style: Theme.of(context).textTheme.titleSmall),
              if (widget.post.location != null)
                Text(widget.post.location!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isLiked) {
    return Row(
      children: [
        IconButton(
          icon: Icon(isLiked ? Icons.favorite : Icons.favorite_border, size: 28),
          onPressed: _likePost,
          color: isLiked ? Colors.red : null,
        ),
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, size: 28),
          onPressed: () {
            context.go('/comments/${widget.post.id}');
          },
        ),
        IconButton(
          icon: const Icon(Icons.send_outlined, size: 28),
          onPressed: () {},
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.bookmark_border, size: 28),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildPostDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${widget.post.likes.length} likes', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              style: DefaultTextStyle.of(context).style,
              children: [
                TextSpan(
                  text: '${_getAuthorUsername()} ',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                TextSpan(
                  text: widget.post.caption,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => context.go('/comments/${widget.post.id}'),
            child: Text(
              'View all ${widget.post.commentCount} comments',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTimestamp(widget.post.timestamp),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
