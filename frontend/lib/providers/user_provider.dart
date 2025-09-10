
import 'package:flutter/material.dart';
import 'package:jivvi/models/user.dart';
import 'package:jivvi/services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService apiService;
  User? _user;
  bool _isLoading = false;

  UserProvider(this.apiService);

  User? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await apiService.register(username, email, password);
      _user = await apiService.getMe();
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
      _user = await apiService.login(email, password);
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

  Future<void> getMe() async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await apiService.getMe();
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
}
