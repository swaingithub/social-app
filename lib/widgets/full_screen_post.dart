
import 'package:flutter/material.dart';

class FullScreenPost extends StatelessWidget {
  const FullScreenPost({
    super.key,
    required this.username,
    required this.avatarUrl,
    required this.imageUrl,
    required this.caption,
  });

  final String username;
  final String avatarUrl;
  final String imageUrl;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background Image
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
        ),
        // Gradient Overlay
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.transparent,
                Colors.black.withOpacity(0.6),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // Post Content
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(avatarUrl),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Caption
              Text(
                caption,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.white, size: 32),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.comment, color: Colors.white, size: 32),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 32),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.bookmark, color: Colors.white, size: 32),
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
