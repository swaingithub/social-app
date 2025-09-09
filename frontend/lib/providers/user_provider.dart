
import 'package:flutter/material.dart';
import 'package:social_media_app/models/user.dart';
import 'package:social_media_app/services/api_service.dart';

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
      // After registering, automatically log in the user
      await login(email, password);
    } catch (e) {
      // Handle error
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
      // After a successful login, fetch the user's data
      // This is a placeholder, as the backend does not yet provide user data upon login
      // _user = await apiService.getLoggedInUser(); 
    } catch (e) {
      // Handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
