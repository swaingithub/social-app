import 'package:flutter/material.dart';
import 'package:jivvi/models/post.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            post.imageUrl,
            fit: BoxFit.cover,
          ),
          _buildGradientOverlay(),
          _buildPostDetails(),
        ],
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.7),
          ],
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
        children: [
          const Icon(Icons.favorite, color: Colors.white, size: 18),
          const SizedBox(width: 4),
          Text(
            post.likes.length.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          const Icon(Icons.comment, color: Colors.white, size: 18),
          const SizedBox(width: 4),
          Text(
            post.comments.length.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
