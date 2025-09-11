import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jivvi/models/post.dart';
import 'package:jivvi/models/user.dart';
import 'package:jivvi/services/api_service.dart';
import 'package:jivvi/widgets/post_card.dart';
import 'package:shimmer/shimmer.dart';

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
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabSelection);
    
    // Initialize user data
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      log('Loading user data...');
      
      // Set up user future
      _userFuture = widget.userId != null
          ? _apiService.getUser(widget.userId!)
          : _apiService.getMe();

      // Set up posts future after user is loaded
      _postsFuture = _userFuture.then((user) {
        log('User data loaded: ${user.username}');
        return _apiService.getPostsByUser(user.id);
      });

      // Trigger a rebuild when the futures complete
      if (mounted) {
        setState(() {});
      }
    } catch (e, stackTrace) {
      log('Error loading user data', error: e, stackTrace: stackTrace);
      if (mounted) {
        setState(() {
          _userFuture = Future.error(e.toString());
        });
      }
    }
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          } else if (snapshot.hasError) {
            return _buildErrorView(snapshot.error.toString());
          } else if (snapshot.hasData) {
            return _buildProfileView(snapshot.data!, Theme.of(context));
          } else {
            return _buildErrorView('No user data available');
          }
        },
      ),
    );
  }

  Widget _buildErrorView(String error) {
    final isUnauthorized = error.contains('401') || error.contains('Not authenticated');
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isUnauthorized ? Icons.lock_outline : Icons.error_outline,
              size: 64,
              color: isUnauthorized ? Colors.orange : Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              isUnauthorized ? 'Authentication Required' : 'Failed to Load Profile',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                isUnauthorized 
                  ? 'Please sign in to view this profile.'
                  : 'We couldn\'t load the profile. Please check your connection and try again.',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[700],
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            if (!isUnauthorized)
              ElevatedButton(
                onPressed: _loadUserData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            if (isUnauthorized) ...[
              ElevatedButton(
                onPressed: () => context.go('/login'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => context.go('/register'),
                child: const Text(
                  'Create New Account',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileView(User user, ThemeData theme) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 450.0,
            backgroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.black),
            pinned: true,
            floating: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/edit-profile', extra: user),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(user, theme),
            ),
            bottom: _buildTabBar(theme),
          ),
        ];
      },
      body: Padding(
        padding: const EdgeInsets.all(4.0),
        child: _buildPostsGrid(),
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
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
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
    return TabBar(
      controller: _tabController,
      indicatorSize: TabBarIndicatorSize.tab,
      indicatorWeight: 3,
      indicator: BoxDecoration(
        borderRadius: BorderRadius.horizontal(
          left: _tabController.index == 0 ? const Radius.circular(10) : Radius.zero,
          right: _tabController.index == 2 ? const Radius.circular(10) : Radius.zero,
        ),
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, spreadRadius: 2)],
      ),
      labelColor: Colors.black,
      unselectedLabelColor: Colors.grey[600],
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
          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
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
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.black)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_enhance, color: Colors.grey[400], size: 80),
                const SizedBox(height: 16),
                const Text(
                  'No Posts Yet',
                  style: TextStyle(color: Colors.grey, fontSize: 22, fontWeight: FontWeight.bold),
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
            children: List.generate(3, (_) => Container(width: 80, height: 50, color: Colors.white)),
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
