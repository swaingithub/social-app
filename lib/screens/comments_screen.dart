import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CommentsScreen extends StatelessWidget {
  final String postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
      ),
      body: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      children: [
                        const CircleAvatar(radius: 20, backgroundColor: Colors.white),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 100,
                              height: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              width: 200,
                              height: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const CircleAvatar(radius: 20, backgroundColor: Colors.white),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 40,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
