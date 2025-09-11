import 'dart:convert';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:jivvi/core/services/api_service.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:jivvi/features/post/models/post.dart';
import 'package:jivvi/features/post/providers/post_provider.dart';
import 'package:jivvi/features/post/screens/comments_screen.dart';
import 'package:jivvi/features/user/screens/profile_screen.dart';
import 'package:jivvi/core/constants/app_colors.dart';
import 'package:share_plus/share_plus.dart';

class PostCard extends StatefulWidget {
  final Post post;
  final String? userId;
  final Function(Post)? onPostUpdated;
  final Function(String)? onPostDeleted;

  const PostCard({
    super.key, 
    required this.post, 
    this.userId,
    this.onPostUpdated,
    this.onPostDeleted,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late Post _post;
  bool _isBookmarked = false;
  bool _isLiked = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
    _isLiked = widget.userId != null && _post.isLikedBy(widget.userId!);
    // Load saved state from local storage if needed
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.post != oldWidget.post) {
      setState(() {
        _post = widget.post;
        _isLiked = widget.userId != null && _post.isLikedBy(widget.userId!);
      });
    }
  }

  void _showMoreOptions() {
    final isCurrentUser = widget.userId == _post.author.id;

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isCurrentUser) _buildListTile('Edit Post', Icons.edit, () {
                Navigator.pop(context);
                _editPost();
              }),
              if (isCurrentUser) _buildListTile('Delete Post', Icons.delete, () {
                Navigator.pop(context);
                _deletePost();
              }),
              if (!isCurrentUser) _buildListTile('Report', Icons.report, () {
                Navigator.pop(context);
                _reportPost();
              }),
              _buildListTile('Share', Icons.share, () {
                Navigator.pop(context);
                _sharePost();
              }),
              _buildListTile('Cancel', Icons.close, () {
                Navigator.pop(context);
              }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildListTile(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title),
      onTap: onTap,
    );
  }

  Future<void> _toggleLike() async {
    if (widget.userId == null) return;

    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _post = _post.copyWith(
          likes: [..._post.likes, widget.userId!]
        );
      } else {
        _post = _post.copyWith(
          likes: _post.likes.where((id) => id != widget.userId).toList()
        );
      }
    });

    try {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      await postProvider.toggleLike(_post.id, widget.userId!);
      
      // Refresh the post data after the like action
      if (mounted) {
        final updatedPost = _post.copyWith(
          likes: _isLiked 
              ? _post.likes.where((id) => id != widget.userId).toList()
              : [..._post.likes, widget.userId!]
        );
        
        setState(() {
          _post = updatedPost;
          _isLiked = !_isLiked;
        });
        widget.onPostUpdated?.call(_post);
      }
    } catch (e) {
      // Revert on error
      setState(() {
        _isLiked = !_isLiked;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update like')),
        );
      }
    }
  }

  Future<void> _toggleBookmark() async {
    // TODO: Implement actual bookmark toggle with API
    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    // Show feedback
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isBookmarked ? 'Post saved' : 'Post removed from saved'),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Future<void> _sharePost() async {
    try {
      await Share.share(
        'Check out this post by ${_post.author.username} on Jivvi!',
        subject: 'Jivvi Post',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to share')),
        );
      }
    }
  }

  Future<void> _editPost() async {
    // TODO: Implement post editing
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Edit post functionality coming soon')),
      );
    }
  }

  Future<void> _deletePost() async {
    if (_isDeleting) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isDeleting = true);

    try {
      final postProvider = Provider.of<PostProvider>(context, listen: false);
      // Call the API directly since PostProvider doesn't have deletePost method
      final response = await http.delete(
        Uri.parse('YOUR_API_BASE_URL/posts/${_post.id}'),
        headers: {
          'Content-Type': 'application/json',
          // Add authorization header if needed
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          widget.onPostDeleted?.call(_post.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Post deleted')),
          );
        }
      } else {
        throw Exception('Failed to delete post');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete post')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  Future<void> _reportPost() async {
    // TODO: Implement post reporting
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report sent. Thank you for your feedback.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileImageUrl = _post.author.profileImageUrl ?? 'https://via.placeholder.com/150';
    final isCurrentUser = widget.userId == _post.author.id;

    void _goToComments() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CommentsScreen(post: _post),
        ),
      );
    }

    void _goToProfile() {
      if (_post.author.id == null) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ProfileScreen(userId: _post.author.id!),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Theme.of(context).colorScheme.surface.withAlpha(240),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _goToProfile,
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(profileImageUrl),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _goToProfile,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: _goToProfile,
                        child: Text(
                          _post.author.username,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        _post.timeAgo, // Using the timeAgo getter
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (_isDeleting)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.more_horiz),
                    onPressed: _showMoreOptions,
                  ),
              ],
            ),
          ),

          // Post Image (tap to view full screen)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => _FullScreenImage(
                      imageUrl: _post.mediaUrl,
                    ),
                  ),
                );
              },
              child: _post.mediaUrl.isNotEmpty
                ? Image.network(
                    _post.mediaUrl,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 300,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300,
                      color: Colors.grey[200],
                      child: const Icon(Icons.error_outline, color: Colors.grey),
                    ),
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  )
                : Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  ),
            ),
          ),

          // Post Actions (Like, Comment, etc.)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? AppColors.likeRed : Colors.grey,
                        size: 30,
                      ),
                      onPressed: _toggleLike,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline, size: 30, color: Colors.grey),
                      onPressed: _goToComments,
                    ),
                    const SizedBox(width: 2),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    size: 26,
                    color: _isBookmarked ? AppColors.primaryColor : Colors.grey,
                  ),
                  onPressed: _toggleBookmark,
                ),
              ],
            ),
          ),

          // Likes Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              '${_post.likes.length} ${_post.likes.length == 1 ? 'like' : 'likes'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // Caption
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '${_post.author.username} ',
                    style: DefaultTextStyle.of(context).style.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    recognizer: TapGestureRecognizer()..onTap = _goToProfile,
                  ),
                  TextSpan(
                    text: _post.caption,
                    style: DefaultTextStyle.of(context).style,
                  ),
                ],
              ),
            ),
          ),

          // View Comments
          GestureDetector(
            onTap: _goToComments,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'View all ${_post.comments.length} ${_post.comments.length == 1 ? 'comment' : 'comments'}',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Related rail
          SizedBox(
            height: 110,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchRelated(_post.id),
              builder: (context, snapshot) {
                if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
                  return const SizedBox.shrink();
                }
                final items = snapshot.data!;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, i) {
                    final r = items[i];
                    final url = (r['mediaUrl'] ?? '').toString();
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: url.isNotEmpty
                        ? Image.network(url, width: 90, height: 110, fit: BoxFit.cover)
                        : Container(width: 90, height: 110, color: Colors.grey[200]),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: items.length.clamp(0, 12),
                );
              },
            ),
          ),
          const SizedBox(height: 15)
        ],
      ),
    );
  }

  Future<List<Map<String, dynamic>>> _fetchRelated(String postId) async {
    try {
      final api = ApiService();
      final res = await http.get(Uri.parse('${api.baseUrl}/posts/$postId/related'));
      if (res.statusCode != 200) return [];
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      final list = body is Map<String, dynamic> && body['data'] is List ? body['data'] : [];
      return List<Map<String, dynamic>>.from(list);
    } catch (_) {
      return [];
    }
  }
}

class _FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const _FullScreenImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          minScale: 0.5,
          maxScale: 4.0,
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            errorBuilder: (context, error, stackTrace) => const Center(
              child: Icon(Icons.error_outline, color: Colors.white, size: 40),
            ),
          ),
        ),
      ),
    );
  }
}
