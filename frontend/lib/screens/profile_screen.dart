import 'package:flutter/material.dart';
import 'package:jivvi/models/post.dart';
import 'package:jivvi/models/user.dart';
import 'package:jivvi/services/api_service.dart';
import 'package:jivvi/widgets/post_card.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final Future<User> _userFuture;
  late Future<List<Post>> _postsFuture;
  final ApiService _apiService = ApiService();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _userFuture = widget.userId != null
        ? _apiService.getUser(widget.userId!)
        : _apiService.getMe();
    _postsFuture =
        _userFuture.then((user) => _apiService.getPostsByUser(user.id));
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
            return Future.value([]);
          case 2:
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
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? Colors.black54 : Colors.white54,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? Colors.black54 : Colors.white54,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.more,
                size: 20,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading profile',
                style: TextStyle(
                  color: isDark ? Colors.white70 : Colors.black54,
                  fontSize: 16,
                ),
              ),
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
    final isDark = theme.brightness == Brightness.dark;

    return NestedScrollView(
      physics: const BouncingScrollPhysics(),
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 380.0,
            backgroundColor: isDark ? Colors.grey[900] : Colors.white,
            iconTheme:
                IconThemeData(color: isDark ? Colors.white : Colors.black),
            pinned: true,
            floating: true,
            elevation: 0,
            flexibleSpace: LayoutBuilder(
              builder: (context, constraints) {
                final scrolled = constraints.biggest.height < 100;
                return FlexibleSpaceBar(
                  collapseMode: CollapseMode.pin,
                  background: _buildHeader(user, theme),
                  title: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: scrolled ? 1.0 : 0.0,
                    child: Text(
                      user.username,
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
            bottom: _buildTabBar(theme),
          ),
        ];
      },
      body: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[900] : Colors.grey[50],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: _buildPostsGrid(),
        ),
      ),
    );
  }

  Widget _buildHeader(User user, ThemeData theme) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepPurple, Colors.pinkAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProfileImage(user, theme),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                user.username,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold),
              ),
              if (user.isVerified)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.verified, color: Colors.blue, size: 24),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (user.location != null && user.location!.isNotEmpty)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_on, color: Colors.white70, size: 16),
                const SizedBox(width: 4),
                Text(
                  user.location!,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          const SizedBox(height: 8),
          if (user.bio != null && user.bio!.isNotEmpty)
            Text(
              user.bio!,
              style: TextStyle(color: Colors.grey[200], fontSize: 16),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 24),
          _buildStatsRow(user, theme),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildTabBar(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return TabBar(
      controller: _tabController,
      isScrollable: false,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorWeight: 3,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(1),
        color: Colors.white,
      ),
      labelColor: Colors.black,
      unselectedLabelColor: Colors.white,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.normal,
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
      tabs: const [
        Tab(text: 'POSTS'),
        Tab(text: 'TAGGED'),
        Tab(text: 'LIKED'),
      ],
    );
  }

  Widget _buildProfileImage(User user, ThemeData theme) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipOval(
        child: user.profileImageUrl != null
            ? Image.network(
                user.profileImageUrl!,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.person, size: 90, color: Colors.black),
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
          style: const TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(color: Colors.grey[200], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPostsGrid() {
    return FutureBuilder<List<Post>>(
      future: _postsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: 9,
            itemBuilder: (context, index) => _buildShimmerPostCard(),
          );
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.black)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_enhance, color: Colors.grey[400], size: 80),
                const SizedBox(height: 16),
                const Text(
                  'No Posts Yet',
                  style: TextStyle(
                      color: Colors.grey,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Create your first post!',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        } else {
          final posts = snapshot.data!;
          return GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 4,
              mainAxisSpacing: 4,
            ),
            itemCount: posts.length,
            itemBuilder: (context, index) => PostCard(post: posts[index]),
          );
        }
      },
    );
  }

  Widget _buildShimmerPostCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          const SizedBox(height: 100),
          const CircleAvatar(radius: 70, backgroundColor: Colors.white),
          const SizedBox(height: 20),
          Container(width: 200, height: 28, color: Colors.white),
          const SizedBox(height: 8),
          Container(width: 150, height: 16, color: Colors.white),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3,
                (_) => Container(width: 80, height: 50, color: Colors.white)),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 4,
                mainAxisSpacing: 4,
              ),
              itemCount: 9,
              itemBuilder: (context, index) => _buildShimmerPostCard(),
            ),
          ),
        ],
      ),
    );
  }
}
