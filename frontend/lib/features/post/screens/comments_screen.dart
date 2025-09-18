import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jivvi/features/post/models/post.dart';
import 'package:jivvi/widgets/comment_card.dart';
import 'package:jivvi/features/post/providers/post_provider.dart';
import 'package:jivvi/features/post/models/comment.dart' as comment_model;

class CommentsScreen extends StatefulWidget {
  final Post post;

  const CommentsScreen({super.key, required this.post});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final _commentController = TextEditingController();
  late Future<List<comment_model.Comment>> _commentsFuture;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  void _fetchComments() {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    _commentsFuture = postProvider.getComments(widget.post.id);
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) return;

    final postProvider = Provider.of<PostProvider>(context, listen: false);
    try {
      await postProvider.addComment(widget.post.id, _commentController.text);
      _commentController.clear();
      setState(() {
        _fetchComments();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add comment: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<comment_model.Comment>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No comments yet.'));
                } else {
                  final comments = snapshot.data!;
                  return ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      return CommentCard(comment: comments[index]);
                    },
                  );
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: const InputDecoration(
                      hintText: 'Add a comment...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _addComment,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
