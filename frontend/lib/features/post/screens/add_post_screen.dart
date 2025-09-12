import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:iconsax/iconsax.dart';
import 'package:jivvi/features/post/providers/post_provider.dart';
import 'package:jivvi/features/misc/screens/trending_music_screen.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _captionController = TextEditingController();
  final _taggedUsersController = TextEditingController();
  File? _image;
  String? _selectedMusic;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _taggedUsersController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Post'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Iconsax.arrow_left),
            onPressed: () => GoRouter.of(context).go('/'),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImagePicker(context),
              const SizedBox(height: 24),
              _buildInputField(context),
              const SizedBox(height: 24),
              _buildMusicSelector(context),
              const SizedBox(height: 100), // Space for the post button
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: _buildPostButton(context, postProvider),
      ),
    );
  }

  Widget _buildImagePicker(BuildContext context) {
    return GestureDetector(
      onTap: _pickImage,
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: const Radius.circular(16),
        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4),
        strokeWidth: 2,
        dashPattern: const [8, 4],
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: _image == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Iconsax.gallery_add,
                      size: 48,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Tap to add a photo or video',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.file(
                    _image!,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _captionController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'Write a caption...',
            prefixIcon: Icon(Iconsax.document_text),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _taggedUsersController,
          decoration: const InputDecoration(
            hintText: 'Tag people',
            prefixIcon: Icon(Iconsax.user_tag),
          ),
        ),
      ],
    );
  }

  Widget _buildMusicSelector(BuildContext context) {
    return ListTile(
      leading: const Icon(Iconsax.music),
      title: Text(_selectedMusic ?? 'Add Music'),
      trailing: const Icon(Iconsax.arrow_right_3),
      onTap: () async {
        final music = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const TrendingMusicScreen(),
          ),
        );
        if (music != null) {
          setState(() {
            _selectedMusic = music;
          });
        }
      },
    );
  }

  Widget _buildPostButton(BuildContext context, PostProvider postProvider) {
    return FloatingActionButton.extended(
      onPressed: _image == null
          ? null
          : () async {
              if (_image != null) {
                await postProvider.createPost(
                  image: _image!,
                  caption: _captionController.text.trim(),
                );
                if (mounted) {
                  GoRouter.of(context).go('/');
                }
              }
            },
      label: postProvider.isLoading
          ? const CircularProgressIndicator(color: Colors.white)
          : const Text('Post'),
      icon: const Icon(Iconsax.send_1),
    );
  }
}
