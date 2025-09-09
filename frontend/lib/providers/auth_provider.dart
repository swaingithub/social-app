import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  User? _user;
  String? _token;

  User? get user => _user;
  String? get token => _token;

  bool get isAuthenticated => _token != null;

  Future<void> register(String username, String email, String password) async {
    final response = await _apiService.post('/users/register', {
      'username': username,
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      _token = responseData['token'];
      await _saveToken(_token!);
      await _getUser();
      notifyListeners();
    } else {
      throw Exception('Failed to register');
    }
  }

  Future<void> login(String email, String password) async {
    final response = await _apiService.post('/users/login', {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      _token = responseData['token'];
      await _saveToken(_token!);
      await _getUser();
      notifyListeners();
    } else {
      throw Exception('Failed to login');
    }
  }

  Future<void> _getUser() async {
    final response = await _apiService.get('/users');
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      _user = User.fromJson(responseData);
    } else {
      throw Exception('Failed to get user');
    }
  }

  Future<void> _saveToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<void> tryAutoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('token')) {
      return;
    }
    _token = prefs.getString('token');
    await _getUser();
    notifyListeners();
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}
