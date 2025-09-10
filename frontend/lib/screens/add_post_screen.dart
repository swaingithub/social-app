
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:jivvi/providers/post_provider.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _captionController = TextEditingController();
  final _taggedUsersController = TextEditingController();
  File? _image;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(bottom: 100), // Padding for floating button
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
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
                        SizedBox(width: 48), // Balance the close button
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Image Input
                  AspectRatio(
                    aspectRatio: 1, // Square aspect ratio
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: theme.dividerColor, width: 1.5),
                          image: _image != null
                              ? DecorationImage(
                                  image: FileImage(_image!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _image == null
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo_library_outlined, size: 60, color: theme.dividerColor),
                                    const SizedBox(height: 16),
                                    Text('Tap to add a photo', style: theme.textTheme.bodyLarge),
                                  ],
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Caption
                  TextField(
                    controller: _captionController,
                    decoration: InputDecoration(
                      hintText: 'Write a caption...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.dividerColor, width: 1),
                      ),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 24),

                  // Tagged Users
                  TextField(
                    controller: _taggedUsersController,
                    decoration: InputDecoration(
                      hintText: 'Tag people (comma separated)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.dividerColor, width: 1),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Additional Actions
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: theme.dividerColor, width: 1),
                    ),
                    child: Column(
                      children: [
                        _buildOptionRow(context, icon: Icons.music_note_outlined, label: 'Add Music'),
                        Divider(height: 1, color: theme.dividerColor),
                        _buildOptionRow(context, icon: Icons.location_on_outlined, label: 'Add Location', isLast: true),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Floating Post Button
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: ElevatedButton(
                onPressed: postProvider.isLoading || _image == null
                    ? null
                    : () {
                        final taggedUsers = _taggedUsersController.text.split(',').map((e) => e.trim()).toList();
                        postProvider
                            .createPost(
                          _captionController.text,
                          _image!.path,
                          taggedUsers,
                        )
                            .then((_) {
                          if (mounted) {
                            context.go('/');
                          }
                        });
                      },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: postProvider.isLoading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white))
                    : const Text('Post', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionRow(BuildContext context, {required IconData icon, required String label, bool isFirst = false, bool isLast = false}) {
    final theme = Theme.of(context);
    final borderRadius = isFirst
        ? const BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12))
        : isLast
            ? const BorderRadius.only(bottomLeft: Radius.circular(12), bottomRight: Radius.circular(12))
            : BorderRadius.zero;

    return InkWell(
      onTap: () {
        // TODO: Implement option functionality
      },
      borderRadius: borderRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
