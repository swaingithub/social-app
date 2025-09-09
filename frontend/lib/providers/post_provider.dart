import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../api/api_service.dart';
import '../models/post.dart';

class PostProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Post> _posts = [];

  List<Post> get posts => _posts;

  Future<void> fetchPosts() async {
    final response = await _apiService.get('/posts');
    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      _posts = responseData.map((data) => Post.fromJson(data)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to fetch posts');
    }
  }

  Future<void> createPost(String caption, String imageUrl) async {
    final response = await _apiService.post('/posts', {
      'caption': caption,
      'imageUrl': imageUrl,
    });

    if (response.statusCode == 200) {
      await fetchPosts();
    } else {
      throw Exception('Failed to create post');
    }
  }
}
