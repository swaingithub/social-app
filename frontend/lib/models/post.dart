class Post {
  final String id;
  final String caption;
  final String imageUrl;
  final String author;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.caption,
    required this.imageUrl,
    required this.author,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'],
      caption: json['caption'],
      imageUrl: json['imageUrl'],
      author: json['author'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
