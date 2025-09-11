import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Text(user.username ?? 'Profile'),
              actions: [
                if (isCurrentUser)
                  IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Log out',
                    onPressed: () async {
                      await userProvider.logout();
                      if (context.mounted) {
                        GoRouter.of(context).go('/login');
                      }
                    },
                  ),
              ],
            ),
            body: DefaultTabController(
              length: 3,
              child: Column(
                children: [
                  // Hero header
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor.withAlpha(36),
                          Theme.of(context).colorScheme.surface,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 16.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              CircleAvatar(
                                radius: 38,
                                backgroundImage: NetworkImage(
                                  user.profileImageUrl ??
                                      'https://via.placeholder.com/150',
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.fullName?.isNotEmpty == true
                                          ? user.fullName!
                                          : (user.username ?? 'Profile'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(
                                            fontWeight: FontWeight.w800,
                                          ),
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        _StatChip(
                                            label: 'Posts',
                                            value: provider.posts.length),
                                        const SizedBox(width: 8),
                                        _StatChip(
                                            label: 'Followers',
                                            value: user.followers.length),
                                        const SizedBox(width: 8),
                                        _StatChip(
                                            label: 'Following',
                                            value: user.following.length),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Actions and bio
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (isCurrentUser)
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditProfileScreen(user: user),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.edit, size: 18),
                                  label: const Text('Edit Profile'),
                                  style: ElevatedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                ),
                              )
                            else
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    final up = Provider.of<UserProvider>(context,
                                        listen: false);
                                    if ((up.user?.following.contains(user.id) ??
                                        false)) {
                                      up.unfollowUser(user.id!);
                                    } else {
                                      up.followUser(user.id!);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                  ),
                                  child: Text(
                                    (Provider.of<UserProvider>(context)
                                            .user
                                            ?.following
                                            .contains(user.id) ??
                                        false)
                                        ? 'Unfollow'
                                        : 'Follow',
                                  ),
                                ),
                              ),
                            const SizedBox(width: 12),
                            OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Icon(Icons.more_horiz),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.bio ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  // Tabs and content
                  const SizedBox(height: 8),
                  const SizedBox(
                    height: 40, // Fixed height for the tab bar
                    child: TabBar(
                      labelColor: Colors.black,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.purple,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelPadding: EdgeInsets.zero,
                      tabs: [
                        Tab(icon: Icon(Icons.grid_on, size: 24)),
                        Tab(icon: Icon(Icons.play_circle_outline, size: 24)),
                        Tab(icon: Icon(Icons.tag, size: 24)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // All posts
                        PostGrid(posts: provider.posts),
                        // Videos: simple filter by file extension
                        PostGrid(
                          posts: provider.posts
                              .where((p) => p.mediaUrl.toLowerCase().endsWith('.mp4') ||
                                  p.mediaUrl.toLowerCase().endsWith('.mov') ||
                                  p.mediaUrl.toLowerCase().endsWith('.webm'))
                              .toList(),
                        ),
                        // Tagged: captions containing '#'
                        PostGrid(
                          posts: provider.posts
                              .where((p) => p.caption.contains('#'))
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  const _StatChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}