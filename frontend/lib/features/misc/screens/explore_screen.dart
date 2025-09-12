import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../features/post/providers/post_provider.dart';
import '../../../features/post/models/post.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch posts when the screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PostProvider>().fetchPosts();
      }
    });
  }

    @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Explore'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Trending'),
              Tab(text: 'Music'),
              Tab(text: 'Gaming'),
              Tab(text: 'Sports'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildExploreGrid(),
            _buildExploreGrid(),
            _buildExploreGrid(),
            _buildExploreGrid(),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreGrid() {
    return Consumer<PostProvider>(
      builder: (context, postProvider, _) {
        if (postProvider.isLoading && postProvider.posts.isEmpty) {
          return _buildLoadingGrid();
        }

        if (postProvider.posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'No posts to show',
                  style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => postProvider.fetchPosts(),
                  child: const Text('Refresh'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => postProvider.fetchPosts(),
          child: MasonryGridView.count(
            padding: const EdgeInsets.all(4),
            crossAxisCount: 2,
            mainAxisSpacing: 4,
            crossAxisSpacing: 4,
            itemCount: postProvider.posts.length,
            itemBuilder: (context, index) {
              final post = postProvider.posts[index];
              final isEven = index % 2 == 0;
              return _buildPostItem(context, post, isEven ? 280 : 200);
            },
          ),
        );
      },
    );
  }

  Widget _buildPostItem(BuildContext context, Post post, double height) {
    return GestureDetector(
      onTap: () {
        // Navigate to post detail screen
        context.push('/post/${post.id}');
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          height: height,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: post.mediaUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
              if (post.mediaUrl.endsWith('.mp4') || post.mediaUrl.endsWith('.mov'))
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(
                    Icons.play_circle_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingGrid() {
    return MasonryGridView.count(
      padding: const EdgeInsets.all(4),
      crossAxisCount: 2,
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      itemCount: 12,
      itemBuilder: (context, index) {
        final isEven = index % 2 == 0;
        return Shimmer.fromColors(
          baseColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
          highlightColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
          child: Container(
            height: isEven ? 280 : 200,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      },
    );
  }
}
