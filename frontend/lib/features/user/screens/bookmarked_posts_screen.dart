import 'package:flutter/material.dart';
import 'package:jivvi/widgets/bookmarked_posts_grid.dart';

class BookmarkedPostsScreen extends StatelessWidget {
  const BookmarkedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked Posts'),
      ),
      body: const BookmarkedPostsGrid(),
    );
  }
}
