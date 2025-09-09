import 'package:flutter/material.dart';
import 'package:social_media_app/models/comment.dart';
import 'package:social_media_app/services/api_service.dart';

class CommentProvider with ChangeNotifier {
  final ApiService _apiService;

  CommentProvider(this._apiService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Comment> _comments = [];
  List<Comment> get comments => _comments;

  Future<void> fetchComments(String postId) async {
    _isLoading = true;
    notifyListeners();

    _comments = await _apiService.getComments(postId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addComment(String postId, String text, String userId) async {
    final newComment = await _apiService.addComment(postId, text, userId);
    _comments.add(newComment);
    notifyListeners();
  }
}
