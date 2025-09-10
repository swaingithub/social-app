import 'package:flutter/material.dart';
import 'package:jivvi/models/article.dart';
import 'package:jivvi/services/news_service.dart';
import 'package:jivvi/theme/app_colors.dart';
import 'package:jivvi/widgets/news_article_list_item.dart';
import 'package:jivvi/widgets/news_article_card_placeholder.dart';
import 'package:jivvi/widgets/search_bar.dart' as custom;

enum NewsCategory {
  all('All'),
  technology('Technology'),
  business('Business'),
  entertainment('Entertainment'),
  health('Health'),
  science('Science'),
  sports('Sports');

  final String name;
  const NewsCategory(this.name);
}

class NewsScreen extends StatefulWidget {
  const NewsScreen({super.key});

  @override
  State<NewsScreen> createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> with SingleTickerProviderStateMixin {
  late Future<List<Article>> _newsFuture;
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  NewsCategory _selectedCategory = NewsCategory.all;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: NewsCategory.values.length, vsync: this);
    _newsFuture = NewsService().getNews();
    
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedCategory = NewsCategory.values[_tabController.index];
          _refreshNews();
        });
      }
    });
  }

  void _refreshNews() {
    setState(() {
      _newsFuture = NewsService().getNews(
        category: _selectedCategory == NewsCategory.all ? null : _selectedCategory.name.toLowerCase(),
        query: _searchQuery.isNotEmpty ? _searchQuery : null,
      );
    });
  }

  void _onSearch(String query) {
    setState(() {
      _searchQuery = query;
      _refreshNews();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120.0,
              floating: true,
              pinned: true,
              backgroundColor: Colors.white,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16),
                title: Text(
                  'Discover',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                centerTitle: false,
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(120),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: custom.SearchBar(
                        controller: _searchController,
                        onChanged: _onSearch,
                        hintText: 'Search for news...',
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: Colors.grey[600],
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: AppColors.primary.withOpacity(0.1),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
                        tabs: NewsCategory.values.map((category) {
                          return Tab(
                            text: category.name,
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        body: FutureBuilder<List<Article>>(
          future: _newsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return const Padding(
                    padding: EdgeInsets.only(bottom: 16.0),
                    child: NewsArticleCardPlaceholder(),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load news\nPlease check your connection and try again',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _refreshNews,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No articles found',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Try adjusting your search or filter',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            } else {
              final articles = snapshot.data!;
              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: articles.length,
                itemBuilder: (context, index) {
                  final article = articles[index];
                  return NewsArticleListItem(article: article);
                },
              );
            }
          },
        ),
      ),
    );
  }
}
