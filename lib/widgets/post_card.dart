import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/providers/feed_provider.dart';

class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.post});

  final Post post;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  late AnimationController _likeAnimationController;
  late Animation<double> _likeAnimation;

  late AnimationController _favoriteIconAnimationController;
  late Animation<double> _favoriteIconAnimation;

  final String currentUserId = 'user_0'; // Hardcoded user ID for now

  @override
  void initState() {
    super.initState();
    _likeAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _likeAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _likeAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _favoriteIconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _favoriteIconAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _favoriteIconAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _likeAnimationController.dispose();
    _favoriteIconAnimationController.dispose();
    super.dispose();
  }

  void _toggleLike(FeedProvider feedProvider) {
    final isLiked = widget.post.likes.contains(currentUserId);
    feedProvider.toggleLike(widget.post.id, currentUserId);
    if (!isLiked) {
      _likeAnimationController.forward().then((_) => _likeAnimationController.reverse());
      _favoriteIconAnimationController.forward().then((_) => _favoriteIconAnimationController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final feedProvider = Provider.of<FeedProvider>(context, listen: false);
    final isLiked = widget.post.likes.contains(currentUserId);

    return GestureDetector(
      onDoubleTap: () => _toggleLike(feedProvider),
      child: Container(
        margin: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.7),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPostHeader(context),
              _buildPostImage(context),
              _buildPostActions(context, feedProvider, isLiked),
              _buildPostDetails(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${widget.post.author}'),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              widget.post.author,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
            color: Theme.of(context).iconTheme.color,
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.network(
          widget.post.imageUrl!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 300,
        ),
        ScaleTransition(
          scale: _favoriteIconAnimation,
          child: const Icon(
            Icons.favorite,
            color: Colors.white,
            size: 100,
          ),
        ),
      ],
    );
  }

  Widget _buildPostActions(BuildContext context, FeedProvider feedProvider, bool isLiked) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: _likeAnimation,
                child: IconButton(
                  icon: Icon(
                    isLiked ? Icons.favorite : Icons.favorite_border,
                    color: isLiked ? Colors.red : Theme.of(context).iconTheme.color,
                    size: 28,
                  ),
                  onPressed: () => _toggleLike(feedProvider),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble_outline, size: 28),
                onPressed: () => context.push('/comments', extra: widget.post),
                color: Theme.of(context).iconTheme.color,
              ),
              IconButton(
                icon: const Icon(Icons.send_outlined, size: 28),
                onPressed: () {},
                color: Theme.of(context).iconTheme.color,
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border, size: 28),
            onPressed: () {},
            color: Theme.of(context).iconTheme.color,
          ),
        ],
      ),
    );
  }

  Widget _buildPostDetails(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.post.likes.length} likes',
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          RichText(
            text: TextSpan(
              style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
              children: [
                TextSpan(
                  text: '${widget.post.author} ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: widget.post.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
