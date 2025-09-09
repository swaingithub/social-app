
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:social_media_app/providers/post_provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _captionController = TextEditingController();
  final _imageUrlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, size: 30),
                    onPressed: () => context.pop(),
                    tooltip: 'Cancel',
                  ),
                  Text(
                    'New Post',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: postProvider.isLoading
                        ? null
                        : () {
                            postProvider
                                .createPost(
                              _captionController.text,
                              _imageUrlController.text,
                            )
                                .then((_) {
                              if (mounted) {
                                context.go('/');
                              }
                            });
                          },
                    child: postProvider.isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : Text(
                            'Share',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Image Preview & Input
              AspectRatio(
                aspectRatio: 1, // Square aspect ratio
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: theme.dividerColor, width: 1.5),
                    image: _imageUrlController.text.isNotEmpty && Uri.parse(_imageUrlController.text).isAbsolute
                        ? DecorationImage(
                            image: NetworkImage(_imageUrlController.text),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _imageUrlController.text.isEmpty || !Uri.parse(_imageUrlController.text).isAbsolute
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_library_outlined, size: 60, color: theme.dividerColor),
                              const SizedBox(height: 16),
                              Text('Your image will appear here', style: theme.textTheme.bodyLarge),
                            ],
                          ),
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _imageUrlController,
                decoration: const InputDecoration(hintText: 'Image URL'),
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 24),

              // Caption
              TextField(
                controller: _captionController,
                decoration: const InputDecoration(
                  hintText: 'Write a caption...',
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 24),

              // Action Buttons
              _buildOptionButton(context, icon: Icons.person_add_outlined, label: 'Tag People'),
              const SizedBox(height: 12),
              _buildOptionButton(context, icon: Icons.music_note_outlined, label: 'Add Music'),
              const SizedBox(height: 12),
              _buildOptionButton(context, icon: Icons.location_on_outlined, label: 'Add Location'),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, {required IconData icon, required String label}) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () {
        // TODO: Implement button functionality
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.dividerColor, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 16),
            Text(label, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
            const Spacer(),
            Icon(Icons.chevron_right, color: theme.dividerColor),
          ],
        ),
      ),
    );
  }
}
