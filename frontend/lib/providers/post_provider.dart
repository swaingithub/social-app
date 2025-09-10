
import 'package:flutter/material.dart';
import 'package:jivvi/models/post.dart';
import 'package:jivvi/services/api_service.dart';

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

  Future<void> createPost(String caption, String imageUrl, List<String> taggedUsers, String? music) async {
    try {
      final newPost = await apiService.createPost(caption, imageUrl, taggedUsers, music);
      _posts.insert(0, newPost);
      notifyListeners();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> toggleLike(String postId) async {
    try {
      // Find the post by id
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex == -1) return;
      
      // Toggle like status
      final post = _posts[postIndex];
      final isLiked = post.likes.contains('currentUserId'); // You might want to replace 'currentUserId' with actual user ID
      
      if (isLiked) {
        post.likes.remove('currentUserId');
      } else {
        post.likes.add('currentUserId');
      }
      
      // Update the post in the list
      _posts[postIndex] = post;
      
      // Notify listeners to rebuild the UI
      notifyListeners();
      
      // Call API to update like status
      await apiService.toggleLike(postId);
    } catch (e) {
      // Handle error, maybe revert the UI change
      notifyListeners();
    }
  }
}
