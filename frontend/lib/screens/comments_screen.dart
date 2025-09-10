import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jivvi/models/post.dart';
import 'package:jivvi/widgets/comment_card.dart';

class CommentsScreen extends StatefulWidget {
  const CommentsScreen({super.key, required this.post});

  final Post post;

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Provider.of<CommentProvider>(context, listen: false).fetchComments(widget.post.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          // Expanded(
          //   child: Consumer<CommentProvider>(
          //     builder: (context, commentProvider, child) {
          //       if (commentProvider.isLoading) {
          //         return const Center(child: CircularProgressIndicator());
          //       }

          //       if (commentProvider.comments.isEmpty) {
          //         return const Center(child: Text('No comments yet.'));
          //       }

          //       return ListView.builder(
          //         itemCount: commentProvider.comments.length,
          //         itemBuilder: (context, index) {
          //           final comment = commentProvider.comments[index];
          //           return CommentCard(
          //             username: comment.author.username,
          //             avatarUrl: comment.author.profileImageUrl,
          //             comment: comment.text,
          //           );
          //         },
          //       );
          //     },
          //   ),
          // ),
          _buildCommentInputField(context),
        ],
      ),
    );
  }

  Widget _buildCommentInputField(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    // final commentProvider = Provider.of<CommentProvider>(context, listen: false);
    const currentUserId = 'user_0'; // Hardcoded user ID for now

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=user_0'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.black.withOpacity(0.5),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_commentController.text.isNotEmpty) {
                // commentProvider.addComment(widget.post.id, _commentController.text, currentUserId);
                _commentController.clear();
              }
            },
            color: colorScheme.primary,
          ),
        ],
      ),
    );
  }
}
