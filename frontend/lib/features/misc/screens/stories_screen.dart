import 'package:flutter/material.dart';
import 'package:jivvi/widgets/stories_bar.dart';
import 'package:jivvi/features/misc/screens/news_screen.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories'),
      ),
      body: const Column(
        children: [
          StoriesBar(),
          SizedBox(height: 16),
          Expanded(
            child: NewsScreen(),
          ),
        ],
      ),
    );
  }
}
