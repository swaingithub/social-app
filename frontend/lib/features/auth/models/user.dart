class User {
  final String? id;
  final String username;
  final String? email;
  final String? profileImageUrl;
  final List<String> followers;
  final List<String> following;
  final List<dynamic> posts;
  final String? fullName;
  final String? bio;
  final String? location;
  final String? website;

  User({
    this.id,
    required this.username,
    this.email,
    this.profileImageUrl = 'https://via.placeholder.com/150',
    required this.followers,
    required this.following,
    this.posts = const [],
    this.fullName,
    this.bio,
    this.location,
    this.website,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString(),
      username: json['username']?.toString() ?? 'Unknown User',
      email: json['email']?.toString() ?? '',
      profileImageUrl: json['profileImageUrl']?.toString() ?? 'https://via.placeholder.com/150',
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
      posts: List<dynamic>.from(json['posts'] ?? []),
      fullName: json['fullName'],
      bio: json['bio'],
      location: json['location'],
      website: json['website'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'followers': followers,
      'following': following,
      'posts': posts,
      'fullName': fullName,
      'bio': bio,
      'location': location,
      'website': website,
    };
  }
}
