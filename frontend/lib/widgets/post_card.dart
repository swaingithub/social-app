import 'package:flutter/material.dart';
import 'package:jivvi/models/post.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.onTap, this.onLike});

  final Post post;
  final VoidCallback? onTap;
  final ValueChanged<bool>? onLike;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Stack(
            fit: StackFit.expand,
            children: [
              post.isVideo
                  ? Stack(
                      alignment: Alignment.center,
                      children: [
                        if (post.thumbnailUrl != null)
                          Image.network(
                            post.thumbnailUrl!,
                            fit: BoxFit.cover,
                          ),
                        const Icon(
                          Icons.play_circle_filled,
                          size: 50,
                          color: Colors.white70,
                        ),
                      ],
                    )
                  : Image.network(
                      post.mediaUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(Icons.error),
                      ),
                    ),
              _buildPostDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostDetails() {
    return Positioned(
      bottom: 8,
      left: 8,
      right: 8,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => onLike?.call(!post.isLikedBy(null)), // Pass actual user ID
            child: Icon(
              post.isLikedBy(null) ? Icons.favorite : Icons.favorite_border,
              color: post.isLikedBy(null) ? Colors.pink : Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '${post.likes.length + (post.isLikedBy(null) ? 0 : 0)}', // Add 1 if current user liked it
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 16),
          const Icon(Icons.comment, color: Colors.grey, size: 22),
          const SizedBox(width: 4),
          Text(
            post.comments.length.toString(),
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
