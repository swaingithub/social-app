import 'package:flutter/material.dart';
import 'package:social_media_app/models/post.dart';
import 'package:social_media_app/services/api_service.dart';

class FeedProvider with ChangeNotifier {
  final ApiService _apiService;

  FeedProvider(this._apiService);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Post> _posts = [];
  List<Post> get posts => _posts;

  Future<void> fetchFeed() async {
    _isLoading = true;
    notifyListeners();

    _posts = await _apiService.getFeed();

    _isLoading = false;
    notifyListeners();
  }
}
