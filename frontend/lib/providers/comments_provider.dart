import 'package:flutter/material.dart';
import 'package:jivvi/features/post/models/comment.dart';
import 'package:jivvi/core/services/api_service.dart';

class CommentsProvider with ChangeNotifier {
  final String postId;
  final ApiService _apiService = ApiService();

  CommentsProvider(this.postId);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Comment> _comments = [];
  List<Comment> get comments => _comments;

  Future<void> fetchComments() async {
    _isLoading = true;
    notifyListeners();

    _comments = await _apiService.getComments(postId);

    _isLoading = false;
    notifyListeners();
  }
}
