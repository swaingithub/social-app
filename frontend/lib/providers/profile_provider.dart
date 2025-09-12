import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jivvi/features/auth/models/user.dart';
import 'package:jivvi/features/post/models/post.dart';
import 'package:jivvi/core/services/api_service.dart';

class ProfileProvider with ChangeNotifier {
  final String userId;
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  User? _user;
  List<Post> _posts = [];

  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  List<Post> get posts => _posts;

  ProfileProvider(this.userId) {
    if (kDebugMode) {
      print('🔄 Initializing ProfileProvider for user ID: $userId');
    }
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    _isLoading = true;
    _hasError = false;
    _errorMessage = null;
    notifyListeners();

    try {
      if (kDebugMode) {
        print('📡 Fetching profile for user: $userId');
      }
      
      // Fetch user data
      _user = await _apiService.getUser(userId);
      
      if (_user == null) {
        throw Exception('User data is null');
      }
      
      if (kDebugMode) {
        print('✅ Successfully fetched user: ${_user?.username} (${_user?.id})');
      }
      
      // Fetch user posts in parallel
      try {
        _posts = await _apiService.getPostsByUser(userId);
        if (kDebugMode) {
          print('📝 Fetched ${_posts.length} posts for user: $userId');
        }
      } catch (postError) {
        // Don't fail the whole request if posts fail to load
        if (kDebugMode) {
          print('⚠️ Error fetching posts: $postError');
        }
        _posts = [];
      }
      
    } catch (e) {
      _hasError = true;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      if (kDebugMode) {
        print('❌ Error fetching profile: $_errorMessage');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void retry() {
    fetchProfile();
  }
}
