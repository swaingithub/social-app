import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media_app/providers/post_provider.dart';
import 'package:social_media_app/widgets/post_card.dart';

import '../widgets/post_placeholder.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Jivvi',
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
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 30,
              spreadRadius: 2,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Consumer<PostProvider>(
          builder: (context, postProvider, child) {
            if (postProvider.isLoading && postProvider.posts.isEmpty) {
              return _buildPostPlaceholders(context);
            }
            return RefreshIndicator(
              onRefresh: () => postProvider.fetchPosts(),
              child: _buildPostListView(postProvider),
            );
          },
        ),
      )
          .animate()
          .scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            curve: Curves.easeOutBack,
            duration: 600.ms,
          )
          .fadeIn(delay: 300.ms),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => context.push('/add-post'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),
      ).animate(
        delay: 1.seconds,
        onPlay: (controller) => controller.repeat(reverse: true),
      ).scale(
        begin: const Offset(0.9, 0.9),
        end: const Offset(1.0, 1.0),
        duration: 1.5.seconds,
        curve: Curves.easeInOut,
      ),
    );
  }

  Widget _buildPostListView(PostProvider postProvider) {
    if (postProvider.posts.isEmpty && !postProvider.isLoading) {
      return const Center(child: Text('No posts yet. Be the first to post!'));
    }
    return ListView.builder(
      itemCount: postProvider.posts.length,
      itemBuilder: (context, index) {
        final post = postProvider.posts[index];
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