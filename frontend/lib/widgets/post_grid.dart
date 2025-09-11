import 'package:flutter/material.dart';
import 'package:jivvi/features/post/models/post.dart';

class PostGrid extends StatelessWidget {
  final List<Post> posts;

  const PostGrid({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return Image.network(
          post.thumbnailUrl ?? post.mediaUrl,
          fit: BoxFit.cover,
        );
      },
    );
  }
}
