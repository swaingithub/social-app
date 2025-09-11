
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:jivvi/models/post.dart';
import 'package:jivvi/services/api_service.dart';

// Using the base Post class which already has comments support

class PostProvider with ChangeNotifier {
  final ApiService apiService;
  List<Post> _posts = [];
  bool _isLoading = false;
  String? _error;
  StreamController<String> _errorController = StreamController<String>.broadcast();

  PostProvider(this.apiService) {
    fetchPosts();
  }

  List<Post> get posts => _posts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Stream<String> get errorStream => _errorController.stream;

  @override
  void dispose() {
    _errorController.close();
    super.dispose();
  }

  Future<void> fetchPosts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fetchedPosts = await apiService.getPosts();
      _posts = fetchedPosts;
      _error = null;
    } catch (e) {
      _error = 'Failed to fetch posts: $e';
      _errorController.add(_error!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Post> createPost({
    required String caption,
    required String mediaUrl,
    String? thumbnailUrl,
    List<String>? taggedUserIds,
    String? music,
    bool isVideo = false,
    bool isPrivate = false,
    List<String>? hashtags,
    List<String>? mentions,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final newPost = await apiService.createPost(
        caption: caption,
        mediaUrl: mediaUrl,
        thumbnailUrl: thumbnailUrl,
        taggedUserIds: taggedUserIds,
        music: music,
        isVideo: isVideo,
        isPrivate: isPrivate,
        hashtags: hashtags,
        mentions: mentions,
      );
      
      _posts.insert(0, newPost);
      notifyListeners();
      return newPost;
    } catch (e) {
      _error = e.toString();
      _errorController.add(_error!);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleLike(String postId) async {
    try {
      // Find the post by id
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex == -1) {
        _error = 'Post not found';
        _errorController.add(_error!);
        return;
      }
      
      // Get current user
      final currentUser = await apiService.getCurrentUser();
      if (currentUser == null) {
        _error = 'You must be logged in to like posts';
        _errorController.add(_error!);
        return;
      }
      
      final isLiked = _posts[postIndex].isLikedBy(currentUser.id);
      
      // Optimistic update
      final oldPost = _posts[postIndex];
      final updatedLikes = isLiked
          ? oldPost.likes.where((user) => user.id != currentUser.id).toList()
          : [...oldPost.likes, currentUser];
      
      _posts[postIndex] = oldPost.copyWith(likes: updatedLikes);
      notifyListeners();
      
      try {
        // Make the API call and handle the response
        final updatedPost = isLiked
            ? await apiService.unlikePost(postId)
            : await apiService.likePost(postId);
            
        if (updatedPost != null) {
          _posts[postIndex] = updatedPost;
          notifyListeners();
        }
      } catch (e) {
        // Revert on error
        _posts[postIndex] = oldPost;
        _error = 'Failed to ${isLiked ? 'unlike' : 'like'} post';
        _errorController.add(_error!);
        notifyListeners();
        rethrow;
      }
    } catch (e) {
      _error = e.toString();
      _errorController.add(_error!);
      rethrow;
    }
  }

  Future<void> addComment({
    required String postId,
    required String text,
    String? parentCommentId,
  }) async {
    try {
      final currentUser = await apiService.getCurrentUser();
      if (currentUser == null) {
        _error = 'You must be logged in to comment';
        _errorController.add(_error!);
        return;
      }
      
      final postIndex = _posts.indexWhere((post) => post.id == postId);
      if (postIndex == -1) {
        _error = 'Post not found';
        _errorController.add(_error!);
        return;
      }
      
      // Optimistic update
      final oldPost = _posts[postIndex];
      final newComment = Comment(
        id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
        text: text,
        author: currentUser,
        parentCommentId: parentCommentId,
        replies: [],
        likeCount: 0,
        isEdited: false,
        createdAt: DateTime.now(),
        updatedAt: null,
      );
      
      _posts[postIndex] = oldPost.copyWith(
        comments: [...oldPost.comments, newComment],
      );
      notifyListeners();
      
      try {
        // Make the API call
        final addedComment = await apiService.addComment(
          postId: postId,
          text: text,
          parentCommentId: parentCommentId,
        );
        
        // Update with server response
        final updatedComments = List<Comment>.from(oldPost.comments)
          ..removeWhere((c) => c.id == newComment.id)
          ..add(Comment.fromJson(addedComment as Map<String, dynamic>));
        
        _posts[postIndex] = oldPost.copyWith(comments: updatedComments);
        notifyListeners();
      } catch (e) {
        // Revert on error
        _posts[postIndex] = oldPost;
        _error = 'Failed to add comment';
        _errorController.add(_error!);
        notifyListeners();
        rethrow;
      }
    } catch (e) {
      _error = e.toString();
      _errorController.add(_error!);
      rethrow;
    }
  }
}
