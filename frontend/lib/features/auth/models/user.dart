class User {
  final String id;
  final String username;
  final String email;
  final String profileImageUrl;
  final List<String> followers;
  final List<String> following;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.profileImageUrl,
    required this.followers,
    required this.following,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
      followers: List<String>.from(json['followers']),
      following: List<String>.from(json['following']),
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
    };
  }
}
