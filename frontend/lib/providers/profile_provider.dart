import 'package:flutter/material.dart';
import 'package:jivvi/features/auth/models/user.dart';
import 'package:jivvi/features/post/models/post.dart';
import 'package:jivvi/core/services/api_service.dart';

class ProfileProvider with ChangeNotifier {
  final String userId;
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  User? _user;
  List<Post> _posts = [];

  bool get isLoading => _isLoading;
  User? get user => _user;
  List<Post> get posts => _posts;

  ProfileProvider(this.userId) {
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _apiService.getUser(userId);
      _posts = await _apiService.getPostsByUser(userId);
    } catch (e) {
      // Handle error, maybe show a message to the user
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
