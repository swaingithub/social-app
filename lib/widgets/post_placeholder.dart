import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class PostPlaceholder extends StatelessWidget {
  const PostPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 20),
                const SizedBox(width: 8),
                Container(
                  width: 100,
                  height: 16,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.white,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  color: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              width: 150,
              height: 16,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            Container(
              width: 250,
              height: 16,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
