import 'package:flutter/material.dart';
import 'package:jivvi/screens/news_screen.dart';
import 'package:jivvi/widgets/stories_bar.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories & News'),
      ),
      body: const Column(
        children: [
          // Stories bar with fixed height
          SizedBox(
            height: 120, // Fixed height for stories bar
            child: StoriesBar(),
          ),
          SizedBox(height: 16),
          // News section taking remaining space
          Expanded(
            child: NewsScreen(),
          ),
        ],
      ),
    );
  }
}
