import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jivvi/features/post/models/post.dart';
import 'package:jivvi/features/post/providers/post_provider.dart';
import 'package:jivvi/features/post/screens/comments_screen.dart';
import 'package:jivvi/features/user/screens/profile_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jivvi/core/services/api_service.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final String? userId;

  const PostCard({super.key, required this.post, this.userId});

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final isLiked = userId != null && post.isLikedBy(userId!);
    final profileImageUrl = post.author.profileImageUrl ?? 'https://via.placeholder.com/150';

    void goToComments() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CommentsScreen(post: post),
        ),
      );
    }

    void goToProfile() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProfileScreen(userId: post.author.id ?? ''),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Theme.of(context).colorScheme.surface.withAlpha(240),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: goToProfile,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: goToProfile,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.author.username,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        post.timeAgo, // Using the timeAgo getter
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_horiz),
                  onPressed: () { /* TODO: Implement more options */ },
                ),
              ],
            ),
          ),

          // Post Image (tap to view full screen)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _FullScreenImage(
                      imageUrl: post.mediaUrl,
                    ),
                  ),
                );
              },
              child: post.mediaUrl.isNotEmpty
                ? Image.network(
                    post.mediaUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 300,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error_outline, color: Colors.grey),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  )
                : Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  ),
            ),
          ),

          // Post Actions (Like, Comment, etc.)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        color: isLiked ? Colors.red : Colors.grey,
                        size: 30,
                      ),
                      onPressed: () {
                        if (userId != null) {
                          postProvider.toggleLike(post.id, userId!);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline, size: 30, color: Colors.grey),
                      onPressed: goToComments,
                    ),
                    const SizedBox(width: 2),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border, size: 26, color: Colors.grey),
                  onPressed: () { /* TODO: Implement save action */ },
                ),
              ],
            ),
          ),

          // Likes Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${post.likes.length} likes',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${post.author.username} ',
                    style: DefaultTextStyle.of(context).style.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    recognizer: TapGestureRecognizer()..onTap = goToProfile,
                  ),
                  TextSpan(
                    text: post.caption,
                    style: DefaultTextStyle.of(context).style,
                  ),
                ],
              ),
            ),
          ),

          // View Comments
          GestureDetector(
            onTap: goToComments,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'View all ${post.comments.length} ${post.comments.length == 1 ? 'comment' : 'comments'}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Related rail
          SizedBox(
            height: 110,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchRelated(post.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                  return const SizedBox.shrink();
                }
                final items = snapshot.data!;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    final r = items[i];
                    final url = (r['mediaUrl'] ?? '').toString();
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: url.isNotEmpty
                        ? Image.network(url, width: 90, height: 110, fit: BoxFit.cover)
                        : Container(width: 90, height: 110, color: Colors.grey[200]),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: items.length.clamp(0, 12),
                );
              },
            ),
          ),
          const SizedBox(height: 15)
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchRelated(String postId) async {
    try {
      final api = ApiService();
      final res = await http.get(Uri.parse('${api.baseUrl}/posts/$postId/related'));
      if (res.statusCode != 200) return [];
      final body = jsonDecode(res.body);
      final list = body is Map<String, dynamic> && body['data'] is List ? body['data'] : [];
      return List<Map<String, dynamic>>.from(list);
    } catch (_) {
      return [];
    }
  }
}

class _FullScreenImage extends StatelessWidget {
  final String imageUrl;
  const _FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topLeft,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
