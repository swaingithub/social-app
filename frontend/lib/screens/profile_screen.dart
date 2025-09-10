import 'package:flutter/material.dart';
import 'package:jivvi/models/post.dart';
import 'package:jivvi/models/user.dart';
import 'package:jivvi/services/api_service.dart';
import 'package:jivvi/widgets/post_card.dart';
import 'package:jivvi/utils/image_utils.dart';
import 'package:shimmer/shimmer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

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
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              // Handle case when there's no route to pop
              // You can navigate to home or any other screen
              context.go('/');
            }
          },
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.more_vert, color: Colors.white),
              ),
              onPressed: () {},
            ),
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
                          radius: 70,
                          backgroundColor: Colors.white,
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 250,
                          height: 20,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: 300,
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
            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  expandedHeight: size.height * 0.35,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        // Cover Photo with gradient overlay
                        Container(
                          height: size.height * 0.35,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                theme.primaryColor.withValues(alpha: 0.7),
                                theme.primaryColor.withValues(alpha: 0.4),
                              ],
                            ),
                          ),
                          child: user.coverImageUrl != null && user.coverImageUrl!.isNotEmpty
                              ? Image.network(
                                  user.coverImageUrl!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => ImageUtils.buildPlaceholderImage(
                                    width: size.width,
                                    height: size.height * 0.35,
                                    text: 'Cover Photo',
                                    backgroundColor: theme.primaryColor.withOpacity(0.5),
                                    textColor: Colors.white,
                                  ),
                                )
                              : ImageUtils.buildPlaceholderImage(
                                  width: size.width,
                                  height: size.height * 0.35,
                                  text: 'Cover Photo',
                                  backgroundColor: theme.primaryColor.withOpacity(0.5),
                                  textColor: Colors.white,
                                ),
                        ),
                        
                        // Profile Info Section
                        Positioned(
                          top: size.height * 0.15,
                          left: 24,
                          right: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Profile Picture
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.primaryColor.withOpacity(0.8),
                                  border: Border.all(color: Colors.white, width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          user.profileImageUrl!,
                                          fit: BoxFit.cover,
                                          width: 120,
                                          height: 120,
                                          errorBuilder: (context, error, stackTrace) => ImageUtils.buildPlaceholderImage(
                                            width: 120,
                                            height: 120,
                                            text: user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                                            backgroundColor: theme.primaryColor.withOpacity(0.8),
                                            textColor: Colors.white,
                                          ),
                                        ),
                                      )
                                    : ImageUtils.buildPlaceholderImage(
                                        width: 120,
                                        height: 120,
                                        text: user.username.isNotEmpty ? user.username[0].toUpperCase() : 'U',
                                        backgroundColor: theme.primaryColor.withOpacity(0.8),
                                        textColor: Colors.white,
                                      ),
                              ),
                              const SizedBox(height: 16),
                              
                              // Username
                              Text(
                                user.username,
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      blurRadius: 5,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Bio
                              if (user.bio != null && user.bio!.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  user.bio!,
                                  textAlign: TextAlign.start,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(top: 20, bottom: 80),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return PostCard(post: posts[index]);
                      },
                      childCount: posts.length,
                    ),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 2,
                      mainAxisSpacing: 2,
                    ),
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