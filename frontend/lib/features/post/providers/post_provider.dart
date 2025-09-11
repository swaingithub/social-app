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
      // Prefer feed endpoint; fallback to global posts
      List<Post> fetched = [];
      try {
        fetched = await _apiService.getFeed();
      } catch (_) {
        fetched = await _apiService.getPosts();
      }
      _posts = fetched;
      if (_posts.isEmpty) {
        // Fallback: fetch current user's posts
        try {
          final me = await _apiService.getMe();
          if (me != null && me.id != null) {
            _posts = await _apiService.getPostsByUser(me.id!);
          }
        } catch (_) {}
      }
    } catch (e) {
      _posts = [];
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
