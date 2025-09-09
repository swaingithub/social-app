import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:social_media_app/widgets/post_card.dart';
import 'package:social_media_app/widgets/stories_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Social Media App',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_box_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.favorite_border),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.send_outlined),
          ),
        ],
      ),
      body: ListView(
        children: [
          const StoriesBar(),
          const Divider(),
          FutureBuilder(
            future: Future.delayed(const Duration(seconds: 2)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return _buildPostPlaceholders();
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

  Widget _buildPostPlaceholders() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 5,
        itemBuilder: (context, index) => const PostPlaceholder(),
      ),
    );
  }
}
