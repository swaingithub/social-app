import 'package:jivvi/models/post.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String profileImageUrl;
  final String? coverImageUrl;
  final String? bio;
  final String? fullName;
  final String? location;
  final String? website;
  final int followerCount;
  final int followingCount;
  final bool isVerified;
  final bool isPrivate;
  final DateTime? lastActive;
  final List<dynamic>? followers;
  final List<dynamic>? following;
  final List<Post>? posts;

  User({
    required this.id,
    required this.username,
    required this.email,
    String? profileImageUrl,
    this.coverImageUrl,
    this.bio,
    this.fullName,
    this.location,
    this.website,
    int? followerCount,
    int? followingCount,
    this.isVerified = false,
    this.isPrivate = false,
    this.lastActive,
    this.followers,
    this.following,
    this.posts,
  }) : profileImageUrl = profileImageUrl ?? 'https://res.cloudinary.com/demo/image/upload/v1621432348/default-avatar.png',
       followerCount = followerCount ?? followers?.length ?? 0,
       followingCount = followingCount ?? following?.length ?? 0;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profileImageUrl: json['profileImageUrl'],
      coverImageUrl: json['coverImageUrl'],
      bio: json['bio'],
      fullName: json['fullName'],
      location: json['location'],
      website: json['website'],
      followerCount: json['followerCount'] ?? json['followers']?.length,
      followingCount: json['followingCount'] ?? json['following']?.length,
      isVerified: json['isVerified'] ?? false,
      isPrivate: json['isPrivate'] ?? false,
      lastActive: json['lastActive'] != null 
          ? DateTime.tryParse(json['lastActive']) 
          : null,
      followers: json['followers'],
      following: json['following'],
      posts: json['posts'] != null 
          ? (json['posts'] as List).map((i) => Post.fromJson(i)).toList() 
          : null,
    );
  }

  // Convert user to map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'coverImageUrl': coverImageUrl,
      'bio': bio,
      'fullName': fullName,
      'location': location,
      'website': website,
      'followerCount': followerCount,
      'followingCount': followingCount,
      'isVerified': isVerified,
      'isPrivate': isPrivate,
      'lastActive': lastActive?.toIso8601String(),
    };
  }

  // Create a copy of the user with updated fields
  User copyWith({
    String? id,
    String? username,
    String? email,
    String? profileImageUrl,
    String? coverImageUrl,
    String? bio,
    String? fullName,
    String? location,
    String? website,
    int? followerCount,
    int? followingCount,
    bool? isVerified,
    bool? isPrivate,
    DateTime? lastActive,
    List<dynamic>? followers,
    List<dynamic>? following,
    List<Post>? posts,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      bio: bio ?? this.bio,
      fullName: fullName ?? this.fullName,
      location: location ?? this.location,
      website: website ?? this.website,
      followerCount: followerCount ?? this.followerCount,
      followingCount: followingCount ?? this.followingCount,
      isVerified: isVerified ?? this.isVerified,
      isPrivate: isPrivate ?? this.isPrivate,
      lastActive: lastActive ?? this.lastActive,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      posts: posts ?? this.posts,
    );
  }

  // Check if the user is followed by another user
  bool isFollowedBy(String? userId) {
    if (userId == null || followers == null) return false;
    return followers!.any((follower) => 
      (follower is Map ? follower['_id']?.toString() : follower.toString()) == userId
    );
  }

  // Check if the user is following another user
  bool isFollowing(String? userId) {
    if (userId == null || following == null) return false;
    return following!.any((followed) => 
      (followed is Map ? followed['_id']?.toString() : followed.toString()) == userId
    );
  }

  // Get display name (full name if available, otherwise username)
  String get displayName => fullName?.isNotEmpty == true ? fullName! : username;

  // Get a short version of the last active time
  String get lastSeen {
    if (lastActive == null) return 'Offline';
    
    final now = DateTime.now();
    final difference = now.difference(lastActive!);
    
    if (difference.inSeconds < 60) return 'Active now';
    if (difference.inMinutes < 60) return 'Active ${difference.inMinutes}m ago';
    if (difference.inHours < 24) return 'Active ${difference.inHours}h ago';
    if (difference.inDays < 7) return 'Active ${difference.inDays}d ago';
    
    return 'Last seen ${lastActive!.day}/${lastActive!.month}/${lastActive!.year}';
  }
}
