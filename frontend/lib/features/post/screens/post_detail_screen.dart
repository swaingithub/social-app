import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jivvi/features/post/providers/post_provider.dart';
import 'package:jivvi/widgets/post_card.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;

  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    final post = context.watch<PostProvider>().getPostById(postId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
      ),
      body: post == null
          ? const Center(
              child: Text('Post not found'),
            )
          : SingleChildScrollView(
              child: PostCard(post: post),
            ),
    );
  }
}