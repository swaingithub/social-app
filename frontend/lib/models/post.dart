import 'package:jivvi/models/user.dart';

class Post {
  final String id;
  final String caption;
  final String mediaUrl;
  final String? thumbnailUrl;
  final User author;
  final List<User> likes;
  final List<Comment> comments;
  final List<User> taggedUsers;
  final String? music;
  final bool isVideo;
  final bool isPrivate;
  final bool isArchived;
  final List<String>? hashtags;
  final List<String>? mentions;
  final int viewCount;
  final int shareCount;
  final int saveCount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Post({
    required this.id,
    required this.caption,
    required this.mediaUrl,
    this.thumbnailUrl,
    required this.author,
    List<User>? likes,
    List<Comment>? comments,
    List<User>? taggedUsers,
    this.music,
    this.isVideo = false,
    this.isPrivate = false,
    this.isArchived = false,
    this.hashtags,
    this.mentions,
    int? viewCount,
    int? shareCount,
    int? saveCount,
    required this.createdAt,
    this.updatedAt,
  }) : likes = likes ?? [],
       comments = comments ?? [],
       taggedUsers = taggedUsers ?? [],
       viewCount = viewCount ?? 0,
       shareCount = shareCount ?? 0,
       saveCount = saveCount ?? 0;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      caption: json['caption'] ?? '',
      mediaUrl: json['mediaUrl'] ?? json['imageUrl'] ?? '',
      thumbnailUrl: json['thumbnailUrl'],
      author: User.fromJson(json['author'] ?? {}),
      likes: (json['likes'] as List?)?.map((i) => User.fromJson(i)).toList() ?? [],
      comments: (json['comments'] as List?)?.map((i) => Comment.fromJson(i)).toList() ?? [],
      taggedUsers: (json['taggedUsers'] as List?)?.map((i) => User.fromJson(i)).toList() ?? [],
      music: json['music'],
      isVideo: json['isVideo'] ?? false,
      isPrivate: json['isPrivate'] ?? false,
      isArchived: json['isArchived'] ?? false,
      hashtags: json['hashtags'] != null ? List<String>.from(json['hashtags']) : null,
      mentions: json['mentions'] != null ? List<String>.from(json['mentions']) : null,
      viewCount: json['viewCount'],
      shareCount: json['shareCount'],
      saveCount: json['saveCount'],
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  // Convert post to map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'caption': caption,
      'mediaUrl': mediaUrl,
      if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
      'author': author.toJson(),
      'likes': likes.map((user) => user.id).toList(),
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'taggedUsers': taggedUsers.map((user) => user.id).toList(),
      if (music != null) 'music': music,
      'isVideo': isVideo,
      'isPrivate': isPrivate,
      'isArchived': isArchived,
      if (hashtags != null) 'hashtags': hashtags,
      if (mentions != null) 'mentions': mentions,
      'viewCount': viewCount,
      'shareCount': shareCount,
      'saveCount': saveCount,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Create a copy of the post with updated fields
  Post copyWith({
    String? id,
    String? caption,
    String? mediaUrl,
    String? thumbnailUrl,
    User? author,
    List<User>? likes,
    List<Comment>? comments,
    List<User>? taggedUsers,
    String? music,
    bool? isVideo,
    bool? isPrivate,
    bool? isArchived,
    List<String>? hashtags,
    List<String>? mentions,
    int? viewCount,
    int? shareCount,
    int? saveCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Post(
      id: id ?? this.id,
      caption: caption ?? this.caption,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      author: author ?? this.author,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      taggedUsers: taggedUsers ?? this.taggedUsers,
      music: music ?? this.music,
      isVideo: isVideo ?? this.isVideo,
      isPrivate: isPrivate ?? this.isPrivate,
      isArchived: isArchived ?? this.isArchived,
      hashtags: hashtags ?? this.hashtags,
      mentions: mentions ?? this.mentions,
      viewCount: viewCount ?? this.viewCount,
      shareCount: shareCount ?? this.shareCount,
      saveCount: saveCount ?? this.saveCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if the post is liked by a specific user
  bool isLikedBy(String? userId) {
    if (userId == null) return false;
    return likes.any((user) => user.id == userId);
  }

  // Get a formatted time since the post was created
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';
    if (difference.inDays < 30) return '${(difference.inDays / 7).floor()}w';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}mo';
    return '${(difference.inDays / 365).floor()}y';
  }
}

class Comment {
  final String id;
  final String text;
  final User author;
  final String? parentCommentId;
  final List<Comment> replies;
  final int likeCount;
  final bool isEdited;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Comment({
    required this.id,
    required this.text,
    required this.author,
    this.parentCommentId,
    List<Comment>? replies,
    int? likeCount,
    this.isEdited = false,
    required this.createdAt,
    this.updatedAt,
  }) : replies = replies ?? [],
       likeCount = likeCount ?? 0;

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      text: json['text'] ?? '',
      author: User.fromJson(json['author'] ?? {}),
      parentCommentId: json['parentCommentId'],
      replies: (json['replies'] as List?)?.map((i) => Comment.fromJson(i)).toList() ?? [],
      likeCount: json['likeCount'] ?? 0,
      isEdited: json['isEdited'] ?? false,
      createdAt: json['createdAt'] != null 
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() 
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  // Convert comment to map for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'author': author.toJson(),
      if (parentCommentId != null) 'parentCommentId': parentCommentId,
      'replies': replies.map((reply) => reply.toJson()).toList(),
      'likeCount': likeCount,
      'isEdited': isEdited,
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  // Create a copy of the comment with updated fields
  Comment copyWith({
    String? id,
    String? text,
    User? author,
    String? parentCommentId,
    List<Comment>? replies,
    int? likeCount,
    bool? isEdited,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Comment(
      id: id ?? this.id,
      text: text ?? this.text,
      author: author ?? this.author,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      replies: replies ?? this.replies,
      likeCount: likeCount ?? this.likeCount,
      isEdited: isEdited ?? this.isEdited,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Get a formatted time since the comment was created
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inSeconds < 60) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 30) return '${difference.inDays}d ago';
    if (difference.inDays < 365) return '${(difference.inDays / 30).floor()}mo ago';
    return '${(difference.inDays / 365).floor()}y ago';
  }
}
