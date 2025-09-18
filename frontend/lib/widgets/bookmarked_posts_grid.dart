import 'package:flutter/material.dart';
import 'package:jivvi/core/services/api_service.dart';
import 'package:jivvi/features/post/models/post.dart';
import 'package:jivvi/widgets/post_grid.dart';

class BookmarkedPostsGrid extends StatefulWidget {
  const BookmarkedPostsGrid({super.key});

  @override
  State<BookmarkedPostsGrid> createState() => _BookmarkedPostsGridState();
}

class _BookmarkedPostsGridState extends State<BookmarkedPostsGrid> {
  final ApiService _apiService = ApiService();
  late Future<List<Post>> _bookmarkedPostsFuture;

  @override
  void initState() {
    super.initState();
    _bookmarkedPostsFuture = _apiService.getBookmarkedPosts();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Post>>(
      future: _bookmarkedPostsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No bookmarked posts yet.'));
        } else {
          return PostGrid(posts: snapshot.data!);
        }
      },
    );
  }
}
