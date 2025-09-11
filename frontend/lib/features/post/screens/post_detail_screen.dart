import 'package:flutter/material.dart';
import 'package:jivvi/features/post/models/post.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;
  final int initialIndex;
  final List<Post> posts;

  const PostDetailScreen({
    super.key,
    required this.post,
    required this.initialIndex,
    required this.posts,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentPost = widget.posts[_currentIndex];
    
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Post',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
      body: PrimaryScrollController(
        controller: _scrollController,
        child: CustomScrollView(
          controller: _scrollController,
        slivers: [
          // Main post content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Post media
                SizedBox(
                  height: MediaQuery.of(context).size.width,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.posts.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final post = widget.posts[index];
                      return InteractiveViewer(
                        child: Image.network(
                          post.mediaUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) => const Center(
                            child: Icon(
                              Icons.error_outline,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Post details
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Like, comment, share buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.favorite_border, color: Colors.white, size: 28),
                                onPressed: () {},
                              ),
                              const SizedBox(width: 16),
                              const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 28),
                              const SizedBox(width: 16),
                              const Icon(Icons.send, color: Colors.white, size: 28),
                            ],
                          ),
                          const Icon(Icons.bookmark_border, color: Colors.white, size: 28),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Like count
                      Text(
                        '${currentPost.likes.length} likes',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Caption
                      if (currentPost.caption.isNotEmpty)
                        Text(
                          currentPost.caption,
                          style: const TextStyle(color: Colors.white),
                        ),
                      const SizedBox(height: 8),
                      // Comments count
                      Text(
                        'View all ${currentPost.comments.length} comments',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Timestamp
                      Text(
                        _formatTimeAgo(currentPost.createdAt),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // More posts header
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'More posts',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Grid of user's other posts
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 2.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2.0,
                mainAxisSpacing: 2.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final post = widget.posts[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                        // Scroll to top when a new post is selected
                        _scrollController.animateTo(
                          0,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      });
                    },
                    child: Image.network(
                      post.mediaUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[900],
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[900],
                        child: const Icon(Icons.error_outline, color: Colors.white54),
                      ),
                    ),
                  );
                },
                childCount: widget.posts.length,
              ),
            ),
          ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
