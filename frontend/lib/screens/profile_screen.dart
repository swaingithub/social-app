import 'package:flutter/material.dart';
import 'package:jivvi/models/post.dart';
import 'package:jivvi/models/user.dart';
import 'package:jivvi/services/api_service.dart';
import 'package:jivvi/widgets/post_card.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late final Future<User> _userFuture;
  late Future<List<Post>> _postsFuture;
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _userFuture = widget.userId != null ? _apiService.getUser(widget.userId!) : _apiService.getMe();
    _postsFuture = _userFuture.then((user) => _apiService.getPostsByUser(user.id));
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      return;
    }

    setState(() {
      _postsFuture = _userFuture.then((user) {
        switch (_tabController.index) {
          case 0:
            return _apiService.getPostsByUser(user.id);
          case 1:
            // Replace with a method to get tagged posts
            return Future.value([]); 
          case 2:
            // Replace with a method to get liked posts
            return Future.value([]);
          default:
            return Future.value([]);
        }
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            final user = snapshot.data!;
            return _buildProfileView(user, theme);
          }
        },
      ),
    );
  }

  Widget _buildProfileView(User user, ThemeData theme) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 400.0,
          backgroundColor: Colors.transparent,
          elevation: 0,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {},
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.black.withOpacity(0.2),
                  ],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  _buildProfileImage(user, theme),
                  const SizedBox(height: 16),
                  Text(
                    user.username,
                    style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (user.bio != null && user.bio!.isNotEmpty)
                    Text(
                      user.bio!,
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 24),
                  _buildStatsRow(user, theme),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: theme.colorScheme.secondary,
            labelColor: theme.colorScheme.secondary,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.grid_on)),
              Tab(icon: Icon(Icons.person_pin_outlined)),
              Tab(icon: Icon(Icons.favorite_border)),
            ],
          ),
        ),
        _buildPostsGrid(),
      ],
    );
  }

  Widget _buildProfileImage(User user, ThemeData theme) {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.white, width: 3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: ClipOval(
          child: user.profileImageUrl != null
              ? Image.network(
                  user.profileImageUrl!,
                  fit: BoxFit.cover,
                )
              : const Icon(
                  Icons.person,
                  size: 80,
                  color: Colors.white,
                ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(User user, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStat('Posts', user.posts?.length ?? 0, theme),
        _buildStat('Followers', user.followerCount, theme),
        _buildStat('Following', user.followingCount, theme),
      ],
    );
  }

  Widget _buildStat(String label, int count, ThemeData theme) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildPostsGrid() {
    return FutureBuilder<List<Post>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SliverToBoxAdapter(
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemCount: 9,
                itemBuilder: (context, index) => Container(color: Colors.white),
              ),
            ),
          );
        } else if (snapshot.hasError) {
          return SliverToBoxAdapter(child: Center(child: Text('Error: ${snapshot.error}')));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(50.0),
                child: Text('No posts yet', style: TextStyle(color: Colors.grey, fontSize: 18)),
              ),
            ),
          );
        } else {
          final posts = snapshot.data!;
          return SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => PostCard(post: posts[index]),
              childCount: posts.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
          );
        }
      },
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400.0,
            backgroundColor: Colors.transparent,
            flexibleSpace: FlexibleSpaceBar(
              background: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  const CircleAvatar(radius: 65, backgroundColor: Colors.white),
                  const SizedBox(height: 16),
                  Container(width: 200, height: 24, color: Colors.white),
                  const SizedBox(height: 8),
                  Container(width: 150, height: 16, color: Colors.white),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(width: 60, height: 40, color: Colors.white),
                      Container(width: 60, height: 40, color: Colors.white),
                      Container(width: 60, height: 40, color: Colors.white),
                    ],
                  ),
                ],
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Theme.of(context).colorScheme.secondary,
              labelColor: Theme.of(context).colorScheme.secondary,
              unselectedLabelColor: Colors.white70,
              tabs: const [
                Tab(icon: Icon(Icons.grid_on)),
                Tab(icon: Icon(Icons.person_pin_outlined)),
                Tab(icon: Icon(Icons.favorite_border)),
              ],
            ),
          ),
          SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) => Container(color: Colors.white),
              childCount: 9,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 2,
              mainAxisSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
