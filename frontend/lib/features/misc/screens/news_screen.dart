import 'package:flutter/material.dart';
import 'package:jivvi/core/services/api_service.dart';
import 'package:jivvi/features/news/models/article.dart';
import 'package:jivvi/widgets/news_article_card.dart';
import 'package:jivvi/widgets/news_article_card_placeholder.dart';

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  late Future<List<Article>> _newsFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _newsFuture = _apiService.getNews();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Article>>(
      future: _newsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const NewsArticleCardPlaceholder(),
          );
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: \${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No news available.'));
        } else {
          final articles = snapshot.data!;
          return ListView.builder(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              return NewsArticleCard(article: articles[index]);
            },
          );
        }
      },
    );
  }
}