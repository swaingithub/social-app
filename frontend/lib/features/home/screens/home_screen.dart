import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:jivvi/features/post/providers/post_provider.dart';
import 'package:jivvi/widgets/post_card.dart';
import 'package:jivvi/widgets/post_placeholder.dart';
import 'package:jivvi/providers/user_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch posts on first load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      if (postProvider.posts.isEmpty) {
        postProvider.fetchPosts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        toolbarHeight: 64,
        centerTitle: false,
        titleSpacing: 16,
        title: Text(
          'Jivvi',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.3,
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border),
                  iconSize: 26,
                ),
                const SizedBox(width: 4),
                IconButton(
                  onPressed: () => context.push('/messages'),
                  icon: const Icon(Icons.message_outlined),
                  iconSize: 26,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).shadowColor.withAlpha(38),
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
              child: _buildPostListView(postProvider, user?.id),
            );
          },
        ),
      ).animate().scale(
            begin: const Offset(0.95, 0.95),
            end: const Offset(1, 1),
            curve: Curves.easeOutBack,
            duration: 600.ms,
          ).fadeIn(delay: 300.ms),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).primaryColor.withAlpha(76),
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
                  Theme.of(context).primaryColor.withAlpha(204),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Icon(
              Icons.add_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 32,
            ),
          ),
        ),
      ).animate(
        delay: 1.seconds,
      ).scale(
        begin: const Offset(0.9, 0.9),
        end: const Offset(1.0, 1.0),
        duration: 1.5.seconds,
        curve: Curves.easeInOut,
      ),
    );
  }

  Widget _buildPostListView(PostProvider postProvider, String? userId) {
    if (postProvider.posts.isEmpty && !postProvider.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'No posts yet. Pull to refresh.\nIf still empty, open your Profile, then come back and pull again.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (userId != null)
                ElevatedButton(
                  onPressed: () {
                    // Navigate to current user's profile
                    context.push('/profile', extra: userId);
                  },
                  child: const Text('Go to Profile'),
                ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 120, top: 8),
      itemCount: postProvider.posts.length,
      itemBuilder: (context, index) {
        final post = postProvider.posts[index];
        return PostCard(post: post, userId: userId);
      },
    );
  }

  Widget _buildPostPlaceholders(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
      highlightColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.15),
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => const PostPlaceholder(),
      ),
    );
  }
}
