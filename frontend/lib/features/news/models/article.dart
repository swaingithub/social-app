class Article {
  final String id;
  final String title;
  final String? description;
  final String? content;
  final String? imageUrl;
  final String? source;
  final String? author;
  final DateTime? publishedAt;
  final String? url;
  final String? urlToImage;

  Article({
    required this.id,
    required this.title,
    this.description,
    this.content,
    this.imageUrl,
    this.source,
    this.author,
    this.publishedAt,
    this.url,
    this.urlToImage,
  });

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      content: json['content'],
      imageUrl: json['imageUrl'] ?? json['urlToImage'],
      source: json['source'] is Map ? json['source']['name'] : json['source'],
      author: json['author'],
      publishedAt: json['publishedAt'] != null 
          ? DateTime.tryParse(json['publishedAt']) 
          : null,
      url: json['url'],
      urlToImage: json['urlToImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'imageUrl': imageUrl,
      'source': source,
      'author': author,
      'publishedAt': publishedAt?.toIso8601String(),
      'url': url,
      'urlToImage': urlToImage,
    };
  }
}
