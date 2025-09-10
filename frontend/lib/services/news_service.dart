import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jivvi/models/article.dart';

class NewsService {
  final String _apiKey = 'YOUR_API_KEY';
  final String _baseUrl = 'https://newsapi.org/v2/top-headlines';

  Future<List<Article>> getNews(String category) async {
    final response = await http.get(Uri.parse('$_baseUrl?category=$category&apiKey=$_apiKey'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['articles'];
      return data.map((article) => Article.fromJson(article)).toList();
    } else {
      throw Exception('Failed to load news');
    }
  }
}
