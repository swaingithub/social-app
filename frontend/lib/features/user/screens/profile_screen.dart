import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:jivvi/features/auth/models/user.dart';
import 'package:jivvi/providers/profile_provider.dart';
import 'package:jivvi/providers/user_provider.dart';
import 'package:jivvi/features/user/screens/edit_profile_screen.dart';
import 'package:jivvi/features/user/screens/settings_screen.dart';
import 'package:jivvi/widgets/post_grid.dart';

class ProfileScreen extends StatelessWidget {
  final String userId;

  const ProfileScreen({super.key, required this.userId});

  void _showMoreOptions(BuildContext context, User user, bool isCurrentUser) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) {
        return Wrap(
          children: <Widget>[
            if (!isCurrentUser) ...[
              ListTile(
                leading: const Icon(Icons.report),
                title: const Text('Report'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle report action
                },
              ),
              ListTile(
                leading: const Icon(Icons.block),
                title: const Text('Block'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle block action
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Profile'),
              onTap: () {
                Navigator.pop(context);
                Share.share('Check out this profile: /user/${user.id}');
              },
            ),
          ],
        );
      },
    );
  }

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
              title: Text(
                user.username ?? 'Profile',
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
              actions: [
                if (isCurrentUser)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
                    onSelected: (value) async {
                      if (value == 'settings') {
                        GoRouter.of(context).push('/settings');
                      } else if (value == 'logout') {
                        await userProvider.logout();
                        if (context.mounted) {
                          GoRouter.of(context).go('/login');
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'settings',
                        child: Text('Settings'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Text('Log out'),
                      ),
                    ],
                  ),
              ],
            ),
            body: DefaultTabController(
              length: 5,
              child: Column(
                children: [
                  // Hero header
                  Container(
                    height: MediaQuery.of(context).size.height > 700 ? 235 : 200,
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
                              Column(
                                mainAxisSize: MainAxisSize.min,
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12),
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
                              onPressed: () =>
                                  _showMoreOptions(context, user, isCurrentUser),
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
                        const SizedBox(height: 4),
                        Text(
                          user.bio ?? '',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  // Tabs and content
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 40,
                    child: TabBar(
                      labelColor: Theme.of(context).colorScheme.primary,
                      unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      indicatorColor: Theme.of(context).colorScheme.primary,
                      indicatorSize: TabBarIndicatorSize.tab,
                      labelPadding: EdgeInsets.zero,
                      tabs: const [
                        Tab(icon: Icon(Icons.grid_on, size: 24)),
                        Tab(icon: Icon(Icons.play_circle_outline, size: 24)),
                        Tab(icon: Icon(Icons.bookmark_border, size: 24)),
                        Tab(icon: Icon(Icons.favorite_border, size: 24)),
                        Tab(icon: Icon(Icons.tag, size: 24)),
                      ],
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // All posts
                        PostGrid(posts: provider.posts),
                        // Videos
                        PostGrid(
                          posts: provider.posts
                              .where((p) =>
                                  p.mediaUrl.toLowerCase().endsWith('.mp4') ||
                                  p.mediaUrl.toLowerCase().endsWith('.mov') ||
                                  p.mediaUrl.toLowerCase().endsWith('.webm'))
                              .toList(),
                        ),
                        // Saved Posts (placeholder)
                        const Center(child: Text('Saved posts will appear here.')),
                        // Liked Posts (placeholder)
                        const Center(child: Text('Liked posts will appear here.')),
                        // Tagged Posts
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
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6))),
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
