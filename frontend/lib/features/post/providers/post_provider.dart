import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jivvi/core/services/api_service.dart';
import 'package:jivvi/features/post/models/post.dart';
import 'package:jivvi/features/post/models/comment.dart' as comment_model;

class PostProvider with ChangeNotifier {
  final ApiService _apiService;
  List<Post> _posts = [];

  PostProvider(this._apiService);
  bool _isLoading = false;

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  Post? getPostById(String id) {
    try {
      return _posts.firstWhere((post) => post.id == id);
    } catch (e) {
      return null;
    }
  }

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
      final post = await _apiService.toggleLike(postId, false);
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        _posts[index] = post;
        notifyListeners();
      }
    } catch (e) {
      // print(e);
    }
  }

  Future<List<comment_model.Comment>> getComments(String postId) async {
    print('PostProvider: getComments called for postId: $postId');
    try {
      final comments = await _apiService.getComments(postId);
      print('PostProvider: getComments received ${comments.length} comments');
      return comments;
    } catch (e) {
      print('PostProvider: Error in getComments: $e');
      rethrow;
    }
  }

  Future<void> addComment(String postId, String text) async {
    print('PostProvider: addComment called for postId: $postId with text: $text');
    try {
      await _apiService.addComment(postId: postId, text: text);
      print('PostProvider: addComment successful');
      final index = _posts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final post = _posts[index];
        final updatedPost = post.copyWith(comments: [...post.comments, comment_model.Comment(id: '', text: text, author: post.author, createdAt: DateTime.now())]);
        _posts[index] = updatedPost;
        notifyListeners();
      }
    } catch (e) {
      print('PostProvider: Error in addComment: $e');
      rethrow;
    }
  }
}
