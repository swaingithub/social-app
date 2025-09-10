import 'package:flutter/material.dart';
import 'package:jivvi/models/comment.dart';

class CommentsProvider with ChangeNotifier {
  final String postId;

  CommentsProvider(this.postId);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Comment> _comments = [];
  List<Comment> get comments => _comments;

  Future<void> fetchComments() async {
    // _isLoading = true;
    // notifyListeners();

    // _comments = await _apiService.getComments(postId);

    // _isLoading = false;
    // notifyListeners();
  }
}
