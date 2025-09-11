import 'package:flutter/material.dart';

class PostPlaceholder extends StatelessWidget {
  const PostPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                CircleAvatar(radius: 20, backgroundColor: Colors.grey[300]),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 100, height: 15, color: Colors.grey[300]),
                    const SizedBox(height: 5),
                    Container(width: 60, height: 12, color: Colors.grey[300]),
                  ],
                ),
              ],
            ),
          ),
          Container(
            height: 300,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 15)
        ],
      ),
    );
  }
}
