import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jivvi/features/post/models/post.dart';
import 'package:jivvi/features/post/providers/post_provider.dart';
import 'package:jivvi/features/post/screens/comments_screen.dart';
import 'package:jivvi/features/user/screens/profile_screen.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final String? userId;

  const PostCard({super.key, required this.post, this.userId});

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final isLiked = userId != null && post.isLikedBy(userId!);

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
          builder: (context) => ProfileScreen(userId: post.author.id),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: goToProfile,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(post.author.profileImageUrl ?? 'https://via.placeholder.com/150'),
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

          // Post Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.network(
              post.mediaUrl, // Using mediaUrl
              fit: BoxFit.cover,
              width: double.infinity,
              height: 300, // Or some other fixed height
            ),
          ),

          // Post Actions (Like, Comment, etc.)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                          postProvider.toggleLike(post.id);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline, size: 30, color: Colors.grey),
                      onPressed: goToComments,
                    ),
                    IconButton(
                      icon: const Icon(Icons.send_outlined, size: 30, color: Colors.grey),
                      onPressed: () { /* TODO: Implement share action */ },
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.bookmark_border, size: 30, color: Colors.grey),
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
                style: DefaultTextStyle.of(context).style,
                children: <TextSpan>[
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: goToProfile,
                      child: Text(
                        '${post.author.username} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  TextSpan(text: post.caption),
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
                'View all ${post.comments.length} comments',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 15)
        ],
      ),
    );
  }
}
