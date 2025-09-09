import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  final String _baseUrl = 'http://localhost:5000/api';

  Future<String?> _getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  Future<http.Response> post(String url, dynamic body) async {
    String? token = await _getToken();
    return await http.post(
      Uri.parse('$_baseUrl$url'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token ?? '',
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String url) async {
    String? token = await _getToken();
    return await http.get(
      Uri.parse('$_baseUrl$url'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'x-auth-token': token ?? '',
      },
    );
  }
}
