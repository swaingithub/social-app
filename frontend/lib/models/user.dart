class User {
  final String id;
  final String username;
  final String email;
  final String? profileImageUrl;
  final String? bio;
  final int followerCount;
  final int followingCount;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profileImageUrl,
    this.bio,
    required this.followerCount,
    required this.followingCount,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      username: json['username'],
      email: json['email'],
      profileImageUrl: json['profileImageUrl'],
      bio: json['bio'],
      followerCount: json['followers']?.length ?? 0,
      followingCount: json['following']?.length ?? 0,
    );
  }
}
