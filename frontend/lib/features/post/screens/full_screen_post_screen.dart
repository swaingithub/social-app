import 'package:flutter/material.dart';
import 'package:jivvi/widgets/full_screen_post.dart';

class FullScreenPostScreen extends StatelessWidget {
  const FullScreenPostScreen({
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: FullScreenPost(
        username: username,
        avatarUrl: avatarUrl,
        imageUrl: imageUrl,
        caption: caption,
      ),
    );
  }
}
