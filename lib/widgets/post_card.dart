import 'package:flutter/material.dart';

class PostCard extends StatelessWidget {
  const PostCard({
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(context),
          _buildPostImage(context),
          _buildPostActions(context),
          _buildPostDetails(context),
        ],
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage(avatarUrl),
          ),
          const SizedBox(width: 12),
          Text(
            username,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
            color: Theme.of(context).iconTheme.color,
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(0), bottom: Radius.circular(0)),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 400,
      ),
    );
  }

  Widget _buildPostActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.favorite_border, size: 28),
            onPressed: () {},
            color: Theme.of(context).iconTheme.color,
          ),
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, size: 28),
            onPressed: () {},
            color: Theme.of(context).iconTheme.color,
          ),
          IconButton(
            icon: const Icon(Icons.send_outlined, size: 28),
            onPressed: () {},
            color: Theme.of(context).iconTheme.color,
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.bookmark_border, size: 28),
            onPressed: () {},
            color: Theme.of(context).iconTheme.color,
          ),
        ],
      ),
    );
  }

  Widget _buildPostDetails(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '1,234 likes',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
              children: [
                TextSpan(
                  text: '$username ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: caption),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'View all 56 comments',
            style: textTheme.bodySmall?.copyWith(color: Colors.grey),
          ),
          const SizedBox(height: 6),
          Text(
            '2 hours ago',
            style: textTheme.bodySmall?.copyWith(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
