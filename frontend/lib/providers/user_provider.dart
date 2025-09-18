import 'package:flutter/material.dart';
import 'package:jivvi/features/auth/models/user.dart';
import 'package:jivvi/core/services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService apiService;
  User? _user;
  bool _isLoading = false;
  List<String> _bookmarkedPostIds = [];

  UserProvider(this.apiService);

  User? get user => _user;
  bool get isLoading => _isLoading;
  List<String> get bookmarkedPostIds => _bookmarkedPostIds;

  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await apiService.register(username, email, password);
      await getMe();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await apiService.login(email, password);
      await getMe();
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  Future<void> fetchBookmarkedPosts() async {
    try {
      final posts = await apiService.getBookmarkedPosts();
      _bookmarkedPostIds = posts.map((post) => post.id).toList();
      notifyListeners();
    } catch (e) {
      // Handle error, maybe log it
    }
  }

  Future<void> getMe() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await apiService.getMe();
      await fetchBookmarkedPosts();
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await apiService.clearToken();
      _user = null;
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateProfile({
    String? username,
    String? fullName,
    String? bio,
    String? location,
    String? website,
    String? profileImageUrl,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      final updatedUser = await apiService.updateProfile(
        username: username,
        fullName: fullName,
        bio: bio,
        location: location,
        website: website,
        profileImageUrl: profileImageUrl,
      );
      _user = updatedUser;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> followUser(String userId) async {
    try {
      await apiService.follow(userId);
      _user = await apiService.getMe(); // Refresh user data
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unfollowUser(String userId) async {
    try {
      await apiService.unfollow(userId);
      _user = await apiService.getMe(); // Refresh user data
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkLoginStatus() async {
    try {
      final token = await apiService.getToken();
      if (token != null && token.isNotEmpty) {
        await getMe();
        return _user != null;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
