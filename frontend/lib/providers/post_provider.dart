
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
      
      // Get current user
      final currentUser = await apiService.getCurrentUser();
      if (currentUser == null) return;
      
      // Toggle like status
      final post = _posts[postIndex];
      final isLiked = post.likes.any((user) => user.id == currentUser.id);
      
      // Call API to update like status
      final updatedPost = isLiked 
          ? await apiService.unlikePost(postId)
          : await apiService.likePost(postId);
      
      if (updatedPost != null) {
        // Update the post in the list with the server response
        _posts[postIndex] = updatedPost;
        notifyListeners();
      }
    } catch (e) {
      // Handle error
      print('Error toggling like: $e');
      // Optionally, you could show an error message to the user
    }
  }
}
