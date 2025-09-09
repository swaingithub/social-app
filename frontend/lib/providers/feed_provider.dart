import 'package:flutter/material.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/services/api_service.dart';

class FeedProvider with ChangeNotifier {
  final ApiService _apiService;

  FeedProvider(this._apiService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  Future<void> fetchFeed() async {
    _isLoading = true;
    notifyListeners();

    _posts = await _apiService.getFeed();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleLike(String postId, String userId) async {
    final postIndex = _posts.indexWhere((post) => post.id == postId);
    if (postIndex == -1) return;

    final post = _posts[postIndex];
    final isLiked = post.likes.contains(userId);

    if (isLiked) {
      post.likes.remove(userId);
    } else {
      post.likes.add(userId);
    }

    notifyListeners();

    try {
      await _apiService.toggleLike(postId, userId);
    } catch (e) {
      // If the API call fails, revert the change
      if (isLiked) {
        post.likes.add(userId);
      } else {
        post.likes.remove(userId);
      }
      notifyListeners();
    }
  }
}
