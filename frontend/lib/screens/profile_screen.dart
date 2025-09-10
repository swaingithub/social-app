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
      backgroundColor: Colors.black,
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerLoading();
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)),
            );
          } else {
            final user = snapshot.data!;
            return _buildProfileView(user, Theme.of(context));
          }
        },
      ),
    );
  }

  Widget _buildProfileView(User user, ThemeData theme) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            expandedHeight: 450.0,
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            pinned: true,
            floating: true,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeader(user, theme),
            ),
            bottom: _buildTabBar(theme),
          ),
        ];
      },
      body: _buildPostsGrid(),
    );
  }

  Widget _buildHeader(User user, ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black, Colors.grey[900]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildProfileImage(user, theme),
          const SizedBox(height: 20),
          Text(
            user.username,
            style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (user.bio != null && user.bio!.isNotEmpty)
            Text(
              user.bio!,
              style: TextStyle(color: Colors.grey[400], fontSize: 16),
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
      indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: theme.colorScheme.secondary,
      ),
      labelColor: Colors.white,
      unselectedLabelColor: Colors.grey[400],
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
        border: Border.all(color: theme.colorScheme.secondary, width: 4),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.secondary.withOpacity(0.4),
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
            : const Icon(Icons.person, size: 90, color: Colors.white),
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
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
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
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white)));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No posts yet', style: TextStyle(color: Colors.grey, fontSize: 18)),
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
      baseColor: Colors.grey[800]!,
      highlightColor: Colors.grey[700]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[900]!,
      highlightColor: Colors.grey[800]!,
      child: Column(
        children: [
          const SizedBox(height: 100),
          const CircleAvatar(radius: 70, backgroundColor: Colors.black),
          const SizedBox(height: 20),
          Container(width: 200, height: 28, color: Colors.black),
          const SizedBox(height: 8),
          Container(width: 150, height: 16, color: Colors.black),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(3, (_) => Container(width: 80, height: 50, color: Colors.black)),
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
