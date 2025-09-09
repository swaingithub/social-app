import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media_app/widgets/post_card.dart';
import 'package:social_media_app/widgets/stories_bar.dart';

import '../widgets/post_placeholder.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
            icon: const Icon(Icons.add_circle_outline),
            iconSize: 28,
          ),
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
      body: ListView(
        children: [
          const StoriesBar(),
          FutureBuilder(
            future: Future.delayed(const Duration(seconds: 2)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildPostPlaceholders(context);
              }
              return _buildPostListView();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPostListView() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, index) => PostCard(
        username: 'user$index',
        imageUrl: 'https://picsum.photos/id/${index + 10}/400/400',
        caption: 'This is a caption for post $index',
        avatarUrl: 'https://i.pravatar.cc/150?u=user$index',
      ),
    );
  }

  Widget _buildPostPlaceholders(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      highlightColor: Theme.of(context).colorScheme.surface.withOpacity(0.8),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) => const PostPlaceholder(),
      ),
    );
  }
}
