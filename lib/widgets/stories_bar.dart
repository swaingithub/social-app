import 'package:flutter/material.dart';

class StoriesBar extends StatelessWidget {
  const StoriesBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 10, // 9 stories + 1 for the user
        itemBuilder: (context, index) {
          if (index == 0) {
            return const _YourStoryAvatar();
          }
          return const _StoryAvatar();
        },
      ),
    );
  }
}

class _StoryAvatar extends StatelessWidget {
  const _StoryAvatar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Colors.yellow.shade600,
                  Colors.orange.shade400,
                  Colors.red.shade500,
                  Colors.pink.shade500,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).cardColor,
                ),
                child: const Padding(
                  padding: EdgeInsets.all(3.0),
                  child: CircleAvatar(
                    backgroundImage: NetworkImage('https://picsum.photos/100'),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text('username', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _YourStoryAvatar extends StatelessWidget {
  const _YourStoryAvatar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              const CircleAvatar(
                radius: 35,
                backgroundImage: NetworkImage('https://picsum.photos/101'),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                    border: Border.all(color: Theme.of(context).scaffoldBackgroundColor, width: 2),
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text('Your Story', style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
