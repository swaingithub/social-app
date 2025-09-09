
import 'package:flutter/material.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/services/api_service.dart';

class PostProvider with ChangeNotifier {
  final ApiService apiService;
  List<Post> _posts = [];
  bool _isLoading = false;

  PostProvider(this.apiService) {
    fetchPosts();
  }

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;

  Future<void> fetchPosts() async {
    _isLoading = true;
    notifyListeners();
    try {
      _posts = await apiService.getPosts();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPost(String caption, String imageUrl) async {
    try {
      final newPost = await apiService.createPost(caption, imageUrl);
      _posts.insert(0, newPost);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }
}
