import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jivvi/features/auth/models/user.dart';
import 'package:jivvi/providers/profile_provider.dart';
import 'package:jivvi/providers/user_provider.dart';
import 'package:jivvi/features/user/screens/edit_profile_screen.dart';
import 'package:jivvi/widgets/post_grid.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isCurrentUser = userId == userProvider.user?.id;

    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(userId),
      child: Consumer<ProfileProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (provider.user == null) {
            return const Scaffold(
              body: Center(child: Text('User not found')),
            );
          }

          final user = provider.user!;

          return Scaffold(
            appBar: AppBar(
              title: Text(user.username),
            ),
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: ProfileHeader(
                      user: user,
                      isCurrentUser: isCurrentUser,
                      currentUser: userProvider.user,
                    ),
                  ),
                ];
              },
              body: PostGrid(posts: provider.posts),
            ),
          );
        },
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final User user;
  final bool isCurrentUser;
  final User? currentUser;

  const ProfileHeader({
    super.key,
    required this.user,
    required this.isCurrentUser,
    this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final isFollowing = currentUser?.following.contains(user.id) ?? false;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                    user.profileImageUrl ?? 'https://via.placeholder.com/150'),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatColumn('Posts', user.posts.length),
                        _buildStatColumn('Followers', user.followers.length),
                        _buildStatColumn('Following', user.following.length),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (isCurrentUser)
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EditProfileScreen(user: user),
                            ),
                          );
                        },
                        child: const Text('Edit Profile'),
                      )
                    else
                      ElevatedButton(
                        onPressed: () {
                          if (isFollowing) {
                            userProvider.unfollowUser(user.id);
                          } else {
                            userProvider.followUser(user.id);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFollowing ? Colors.grey : Theme.of(context).primaryColor,
                        ),
                        child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                      )
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.fullName ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(user.bio ?? ''),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, int number) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          number.toString(),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 15, color: Colors.grey),
        ),
      ],
    );
  }
}
