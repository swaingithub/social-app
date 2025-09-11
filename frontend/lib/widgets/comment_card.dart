import 'package:flutter/material.dart';
import 'package:jivvi/features/post/models/comment.dart';
import 'package:jivvi/features/user/screens/profile_screen.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;

  const CommentCard({super.key, required this.comment});

  @override
  Widget build(BuildContext context) {
    void goToProfile() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProfileScreen(userId: comment.author.id),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: goToProfile,
              child: CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(comment.author.profileImageUrl ?? 'https://via.placeholder.com/150'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(context).style,
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: goToProfile,
                            child: Text(
                              '${comment.author.username} ',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        TextSpan(text: comment.text),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    comment.timeAgo,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite_border, size: 20, color: Colors.grey),
              onPressed: () { /* TODO: Implement like comment */ },
            ),
          ],
        ),
      ),
    );
  }
}
