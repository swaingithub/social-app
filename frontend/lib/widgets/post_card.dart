
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/providers/post_provider.dart';

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

  void _toggleLike(PostProvider postProvider) {
    final isLiked = widget.post.likes.contains(currentUserId);
    postProvider.toggleLike(widget.post.id);
    if (!isLiked) {
      _likeAnimationController.forward().then((_) => _likeAnimationController.reverse());
      _favoriteIconAnimationController.forward().then((_) => _favoriteIconAnimationController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final isLiked = widget.post.likes.contains(currentUserId);

    return GestureDetector(
      onDoubleTap: () => _toggleLike(postProvider),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface.withOpacity(0.8),
              colorScheme.surface,
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, -10),
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
              _buildPostActions(context, postProvider, isLiked),
              _buildPostDetails(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${widget.post.author.profileImageUrl}'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              widget.post.author.username,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          IconButton(
            icon: SvgPicture.asset('assets/icons/more.svg', colorFilter: ColorFilter.mode(Theme.of(context).iconTheme.color!, BlendMode.srcIn)),
            onPressed: () {},
            iconSize: 30,
          ),
        ],
      ),
    );
  }

  Widget _buildPostImage(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            widget.post.imageUrl,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 350,
          ),
        ),
        ScaleTransition(
          scale: _favoriteIconAnimation,
          child: SvgPicture.asset(
            'assets/icons/like.svg',
            colorFilter: const ColorFilter.mode(Colors.white70, BlendMode.srcIn),
            width: 120,
            height: 120,
          ),
        ),
      ],
    );
  }

  Widget _buildPostActions(BuildContext context, PostProvider postProvider, bool isLiked) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ScaleTransition(
                scale: _likeAnimation,
                child: IconButton(
                  icon: SvgPicture.asset(
                    'assets/icons/like.svg',
                    colorFilter: ColorFilter.mode(
                      isLiked ? Colors.redAccent : colorScheme.onSurface,
                      BlendMode.srcIn,
                    ),
                    width: 32,
                    height: 32,
                  ),
                  onPressed: () => _toggleLike(postProvider),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: SvgPicture.asset('assets/icons/comment.svg', width: 32, height: 32, colorFilter: ColorFilter.mode(colorScheme.onSurface, BlendMode.srcIn)),
                onPressed: () => context.push('/comments', extra: widget.post),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: SvgPicture.asset('assets/icons/send.svg', width: 32, height: 32, colorFilter: ColorFilter.mode(colorScheme.onSurface, BlendMode.srcIn)),
                onPressed: () {},
              ),
            ],
          ),
          IconButton(
            icon: SvgPicture.asset('assets/icons/bookmark.svg', width: 32, height: 32, colorFilter: ColorFilter.mode(colorScheme.onSurface, BlendMode.srcIn)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildPostDetails(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.post.likes.length} likes',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface, height: 1.4),
              children: [
                TextSpan(
                  text: '${widget.post.author.username} ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: widget.post.caption),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
