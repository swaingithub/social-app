import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jivvi/models/article.dart';
import 'dart:io';

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

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((article) => Article.fromJson(article)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}
