import 'package:flutter/material.dart';

class PostPlaceholder extends StatelessWidget {
  const PostPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPostHeader(),
          _buildPostImage(),
          _buildPostActions(),
          _buildPostDetails(),
        ],
      ),
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
          ),
          const SizedBox(width: 10),
          Container(
            width: 100,
            height: 16,
            color: Colors.white,
          ),
          const Spacer(),
          Container(
            width: 24,
            height: 24,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage() {
    return Container(
      width: double.infinity,
      height: 400,
      color: Colors.white,
    );
  }

  Widget _buildPostActions() {
    return Row(
      children: [
        const SizedBox(width: 12),
        Container(
          width: 28,
          height: 28,
          color: Colors.white,
        ),
        const SizedBox(width: 12),
        Container(
          width: 28,
          height: 28,
          color: Colors.white,
        ),
        const SizedBox(width: 12),
        Container(
          width: 28,
          height: 28,
          color: Colors.white,
        ),
        const Spacer(),
        Container(
          width: 28,
          height: 28,
          color: Colors.white,
        ),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildPostDetails() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 100,
            height: 16,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Container(
            width: 200,
            height: 16,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Container(
            width: 150,
            height: 16,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
