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
    // Handle followers - can be either array of strings or array of user objects
    List<String> parseFollowers(dynamic followersData) {
      if (followersData == null) return [];
      if (followersData is List) {
        return followersData.map((follower) {
          if (follower is String) return follower;
          if (follower is Map && follower['_id'] != null) {
            return follower['_id'].toString();
          }
          return '';
        }).where((id) => id.isNotEmpty).toList();
      }
      return [];
    }

    // Handle following - can be either array of strings or array of user objects
    List<String> parseFollowing(dynamic followingData) {
      if (followingData == null) return [];
      if (followingData is List) {
        return followingData.map((user) {
          if (user is String) return user;
          if (user is Map && user['_id'] != null) {
            return user['_id'].toString();
          }
          return '';
        }).where((id) => id.isNotEmpty).toList();
      }
      return [];
    }

    return User(
      id: json['_id']?.toString(),
      username: json['username']?.toString() ?? 'Unknown User',
      email: json['email']?.toString() ?? '',
      profileImageUrl: json['profileImageUrl']?.toString() ?? 'https://via.placeholder.com/150',
      followers: parseFollowers(json['followers']),
      following: parseFollowing(json['following']),
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
