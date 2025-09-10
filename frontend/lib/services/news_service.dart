import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jivvi/models/article.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

class NewsService {
  late final String baseUrl;

  NewsService() {
    if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:5000/api';
    } else {
      baseUrl = 'http://localhost:5000/api';
    }
  }

  Future<List<Article>> getNews({String? category, String? query}) async {
    final uri = Uri.parse('$baseUrl/news').replace(
      queryParameters: {
        if (category != null) 'category': category,
        if (query != null) 'q': query,
      },
    );

    final response = await http.get(uri);

    // Print the response to the debug console
    if (kDebugMode) {
      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');
    }

    if (response.statusCode == 200) {
      try {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((article) => Article.fromJson(article)).toList();
      } catch (e) {
        if (kDebugMode) {
          print('Error decoding news: $e');
        }
        throw Exception('Failed to parse news data');
      }
    } else {
      throw Exception('Failed to load news');
    }
  }
}
