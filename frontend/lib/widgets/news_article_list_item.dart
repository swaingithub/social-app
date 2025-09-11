import 'package:flutter/material.dart';
import 'package:jivvi/widgets/news_article_card.dart';
import 'package:jivvi/features/news/models/article.dart';

class NewsArticleListItem extends StatefulWidget {
  final Article article;

  const NewsArticleListItem({super.key, required this.article});

  @override
  State<NewsArticleListItem> createState() => _NewsArticleListItemState();
}

class _NewsArticleListItemState extends State<NewsArticleListItem> with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: NewsArticleCard(article: widget.article),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
