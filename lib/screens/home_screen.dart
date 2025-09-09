import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media_app/providers/feed_provider.dart';
import 'package:social_media_app/widgets/post_card.dart';

import '../widgets/post_placeholder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the feed when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeedProvider>(context, listen: false).fetchFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Claymorphic Social',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
            iconSize: 28,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.send_outlined),
            iconSize: 28,
          ),
        ],
      ),
      body: Consumer<FeedProvider>(
        builder: (context, feedProvider, child) {
          if (feedProvider.isLoading) {
            return _buildPostPlaceholders(context);
          }
          return _buildPostListView(feedProvider);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add-post'),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildPostListView(FeedProvider feedProvider) {
    return ListView.builder(
      itemCount: feedProvider.posts.length,
      itemBuilder: (context, index) {
        final post = feedProvider.posts[index];
        return PostCard(post: post);
      },
    );
  }

  Widget _buildPostPlaceholders(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      highlightColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => const PostPlaceholder(),
      ),
    );
  }
}
