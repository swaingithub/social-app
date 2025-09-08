import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/theme/theme_provider.dart';
import 'package:social_media_app/widgets/post_card.dart';
import 'package:social_media_app/widgets/post_placeholder.dart';
import 'package:social_media_app/widgets/stories_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SocialApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
                context.watch<ThemeProvider>().themeMode == ThemeMode.dark
                    ? Icons.light_mode
                    : Icons.dark_mode),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          const StoriesBar(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => const PostPlaceholder(),
                  );
                } else if (snapshot.hasError) {
                  return const Center(child: Text('An error occurred.'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No posts yet.'));
                } else {
                  final posts = snapshot.data!.docs
                      .map((doc) => Post.fromMap(
                          doc.data() as Map<String, dynamic>, doc.id))
                      .toList();
                  return ListView.builder(
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      final post = posts[index];
                      return PostCard(post: post);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.go('/create-post');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
