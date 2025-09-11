import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jivvi/core/services/api_service.dart';
import 'package:jivvi/features/post/models/post.dart';

class PostProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Post> _posts = [];
  bool _isLoading = false;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _posts = await _apiService.getPosts();
    } catch (e) {
      // print(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<Post> createPost({
    required String caption,
    required File image,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final mediaUrl = await _apiService.uploadImage(image);
      final post = await _apiService.createPost(
        caption: caption,
        mediaUrl: mediaUrl,
      );
      _posts.insert(0, post);
      _isLoading = false;
      notifyListeners();
      return post;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> toggleLike(String postId, String userId) async {
    try {
      final post = await _apiService.toggleLike(postId);
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _posts[index] = post;
        notifyListeners();
      }
    } catch (e) {
      // print(e);
    }
  }
}
