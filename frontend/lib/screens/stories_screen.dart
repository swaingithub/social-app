import 'package:flutter/material.dart';
import 'package:jivvi/widgets/stories_bar.dart';

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories & News'),
      ),
      body: ListView(
        children: [
          const StoriesBar(),
          const SizedBox(height: 16),
          _buildNewsFeed(),
        ],
      ),
    );
  }

  Widget _buildNewsFeed() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Latest News',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 10, // Placeholder for news items
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ListTile(
                leading: const Icon(Icons.article),
                title: Text('News Headline ${index + 1}'),
                subtitle: const Text('This is a short description of the news article.'),
                onTap: () {},
              ),
            );
          },
        ),
      ],
    );
  }
}
