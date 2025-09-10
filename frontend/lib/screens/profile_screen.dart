import 'package:flutter/material.dart';
import 'package:jivvi/models/post.dart';
import 'package:jivvi/models/user.dart';
import 'package:jivvi/services/api_service.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final Future<User> _userFuture;
  late final Future<List<Post>> _postsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _userFuture = widget.userId != null ? _apiService.getUser(widget.userId!) : _apiService.getMe();
    _postsFuture = _userFuture.then((user) => _apiService.getPostsByUser(user.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: FutureBuilder<List<Object>>(
        future: Future.wait([_userFuture, _postsFuture]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 150,
                          height: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 250,
                          height: 16,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: 9,
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.white,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final user = snapshot.data![0] as User;
            final posts = snapshot.data![1] as List<Post>;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(user.profilePictureUrl ?? 'https://www.brinkleys.org/wp-content/uploads/2018/08/dummy-200x200.png'),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user.username,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        user.bio ?? '',
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 4,
                      mainAxisSpacing: 4,
                    ),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return Image.network(
                        posts[index].imageUrl,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}