import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jivvi/features/post/models/comment.dart' as comment_model;
import 'package:jivvi/features/post/models/post.dart';
import 'package:jivvi/features/auth/models/user.dart';
import 'package:jivvi/features/news/models/article.dart';

class ApiService {
  final String baseUrl;
  final String fileBaseUrl;

  ApiService()
      : baseUrl = Platform.isAndroid
            ? 'http://10.0.2.2:5000/api'
            : 'http://localhost:5000/api',
        fileBaseUrl = Platform.isAndroid
            ? 'http://10.0.2.2:5000'
            : 'http://localhost:5000';

  String getImageUrl(String? path) {
    print('getImageUrl called with path: $path');
    if (path == null || path.isEmpty) {
      print('getImageUrl returning default image');
      return 'https://res.cloudinary.com/demo/image/upload/v1621432348/default-avatar.png';
    }
    
    // If it's already a full URL, return as is
    if (path.startsWith('http')) {
      print('getImageUrl returning path as is: $path');
      return path;
    }
    
    // Handle Windows paths if needed
    String normalizedPath = path.replaceAll(r'\', '/');
    
    // Remove leading slashes to prevent double slashes
    while (normalizedPath.startsWith('/')) {
      normalizedPath = normalizedPath.substring(1);
    }
    
    // Construct the final URL
    final url = '$fileBaseUrl/$normalizedPath';
    
    if (kDebugMode) {
      print('Generated image URL: $url');
    }
    
    return url;
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Public method to get the authentication token
  Future<String?> getToken() => _getToken();

  Future<void> _setToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  // Get the current authenticated user
  Future<User?> getCurrentUser() async {
    try {
      return await getMe();
    } catch (e) {
      return null;
    }
  }

  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // Lightweight helpers for internal providers (chat)
  Future<dynamic> _getWithAuth(String path) async {
    final headers = await _getHeaders();
    final res = await http.get(Uri.parse('$baseUrl$path'), headers: headers);
    if (res.statusCode == 200) {
      final body = jsonDecode(res.body);
      return body['data'] ?? body;
    }
    throw Exception('GET $path failed (${res.statusCode})');
  }

  Future<dynamic> _postWithAuth(String path, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final res = await http.post(Uri.parse('$baseUrl$path'), headers: headers, body: jsonEncode(body));
    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return data['data'] ?? data;
    }
    throw Exception('POST $path failed (${res.statusCode})');
  }

  // Public chat APIs
  Future<List<dynamic>> getConversations() async {
    final data = await _getWithAuth('/chat/conversations');
    return List<dynamic>.from(data ?? []);
  }

  Future<Map<String, dynamic>> createOrGetConversation(String userId) async {
    final data = await _postWithAuth('/chat/conversations/$userId', {});
    return Map<String, dynamic>.from(data ?? {});
  }

  Future<List<dynamic>> getMessages(String conversationId) async {
    final data = await _getWithAuth('/chat/messages/$conversationId');
    return List<dynamic>.from(data ?? []);
  }

  Future<Map<String, dynamic>> sendChatMessage(String conversationId,
      {String text = '', String mediaUrl = ''}) async {
    final data = await _postWithAuth('/chat/messages/$conversationId', {
      if (text.isNotEmpty) 'text': text,
      if (mediaUrl.isNotEmpty) 'mediaUrl': mediaUrl,
    });
    return Map<String, dynamic>.from(data ?? {});
  }

  Future<List<Article>> fetchNews() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/news'),
        headers: await _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Article.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }

  Future<String> uploadImage(File image) async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication required. Please log in.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/files/upload'),
    );
    request.headers['x-auth-token'] = token;
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final data = jsonDecode(responseBody);
      return data['mediaUrl'];
    } else {
      throw Exception('Failed to upload image');
    }
  }

  Future<void> register(String username, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _setToken(data['token']);
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['msg'] ?? 'Failed to register');
    }
  }

  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _setToken(data['token']);
      return await getMe();
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['msg'] ?? 'Failed to login');
    }
  }

  Future<User> getMe() async {
    try {
      // print('Getting authentication token...');
      final token = await _getToken();
      // print('Token: ${token != null ? 'Token exists' : 'Token is null'}');
      
      if (token == null || token.isEmpty) {
        // print('No authentication token found');
        throw Exception('Not authenticated. Please log in again.');
      }

      final url = Uri.parse('$baseUrl/users/me');
      // print('Making request to: $url');
      
      try {
        final response = await http.get(
          url,
          headers: {
            'Content-Type': 'application/json',
            'x-auth-token': token,
          },
        ).timeout(
          const Duration(seconds: 10),
          onTimeout: () => throw http.ClientException(
            'Connection timed out',
            url,
          ),
        );

        // print('Response status: ${response.statusCode}');
        // print('Response headers: ${response.headers}');
        
        // Handle empty response body
        if (response.body.isEmpty) {
          throw Exception('Empty response from server');
        }

        dynamic responseBody;
        try {
          responseBody = jsonDecode(response.body);
          // print('Parsed response body: $responseBody');
        } catch (e) {
          // print('Failed to parse response body: ${response.body}');
          throw Exception('Invalid server response format');
        }
        
        if (response.statusCode == 200) {
          try {
            if (responseBody is Map<String, dynamic>) {
              if (responseBody['success'] == true && responseBody['data'] != null) {
                return User.fromJson(responseBody['data']);
              } else {
                final errorMsg = responseBody['msg'] ?? 'Invalid response format';
                // print('API Error: $errorMsg');
                if (responseBody['error'] != null) {
                  // print('Additional error info: ${responseBody['error']}');
                }
                throw Exception(errorMsg);
              }
            } else {
              throw Exception('Unexpected response format');
            }
          } catch (e) {
            // print('Error parsing user data: $e');
            throw Exception('Failed to parse user data: $e');
          }
        } else if (response.statusCode == 401) {
          // print('Authentication failed - invalid or expired token');
          await clearToken();
          throw Exception(responseBody is Map 
              ? responseBody['msg'] ?? 'Session expired. Please log in again.'
              : 'Session expired. Please log in again.');
        } else {
          final errorMsg = responseBody is Map 
              ? responseBody['msg'] ?? 'Failed to get user (Status: ${response.statusCode})'
              : 'Failed to get user (Status: ${response.statusCode})';
          // print('Server error: $errorMsg');
          throw Exception(errorMsg);
        }
      } on http.ClientException catch (e) {
        if (e.message.contains('timed out')) {
          // print('Request timed out');
          throw Exception('Request timed out. Please check your connection and try again.');
        }
        // print('HTTP Client Exception: $e');
        throw Exception('Network error: ${e.message}');
      } on FormatException catch (e) {
        // print('Format Exception: $e');
        throw Exception('Invalid server response format');
      } catch (e) {
        // print('Unexpected error in getMe: $e');
        throw Exception('An unexpected error occurred. Please try again.');
      }
    } catch (e) {
      // print('Exception in getMe: $e');
      rethrow;
    }
  }

  Future<List<Post>> getPosts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/posts'));
      if (response.statusCode != 200) {
        throw Exception('Failed with ${response.statusCode}');
      }
      final decoded = jsonDecode(response.body);
      final List<dynamic> list = decoded is List
          ? decoded
          : (decoded is Map<String, dynamic> && decoded['data'] is List
              ? decoded['data']
              : <dynamic>[]);
      return list.map((post) => Post.fromJson(Map<String, dynamic>.from(post))).toList();
    } catch (e) {
      throw Exception('Failed to load posts: $e');
    }
  }

  Future<List<Post>> getFeed() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/feed'),
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'x-auth-token': token,
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to load feed');
    }
    final body = jsonDecode(response.body);
    final List<dynamic> list = body is Map<String, dynamic> && body['data'] is List
        ? body['data']
        : (body is List ? body : <dynamic>[]);
    return list.map((post) => Post.fromJson(Map<String, dynamic>.from(post))).toList();
  }

  Future<Post> createPost({
    required String caption,
    required String mediaUrl,
    String? thumbnailUrl,
    List<String>? taggedUserIds,
    String? music,
    bool isVideo = false,
    bool isPrivate = false,
    List<String>? hashtags,
    List<String>? mentions,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please log in.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/posts'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode({
          'caption': caption,
          'mediaUrl': mediaUrl,
          if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
          if (taggedUserIds != null && taggedUserIds.isNotEmpty) 'taggedUsers': taggedUserIds,
          if (music != null) 'music': music,
          'isVideo': isVideo,
          'isPrivate': isPrivate,
          if (hashtags != null && hashtags.isNotEmpty) 'hashtags': hashtags,
          if (mentions != null && mentions.isNotEmpty) 'mentions': mentions,
        }),
      );

      // print('Create post response: ${response.statusCode}');
      // print('Response body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (responseBody is Map<String, dynamic> && responseBody['success'] == true) {
          return Post.fromJson(responseBody['data']);
        } else {
          throw Exception(responseBody['msg'] ?? 'Invalid response format');
        }
      } else if (response.statusCode == 401) {
        await clearToken();
        throw Exception('Session expired. Please log in again.');
      } else {
        final errorMsg = responseBody is Map 
            ? responseBody['msg'] ?? 'Failed to create post'
            : 'Failed to create post';
        throw Exception(errorMsg);
      }
    } catch (e) {
      // print('Exception in createPost: $e');
      rethrow;
    }
  }

  Future<Post> toggleLike(String postId, bool isLiked) async {
    final endpoint = isLiked ? 'unlike' : 'like';
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please log in.');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/posts/$endpoint/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody is Map<String, dynamic> && responseBody['success'] == true) {
          return Post.fromJson(responseBody['data']);
        } else {
          throw Exception(responseBody['msg'] ?? 'Invalid response format');
        }
      } else if (response.statusCode == 401) {
        await clearToken();
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Post not found');
      } else {
        final errorMsg = responseBody is Map
            ? responseBody['msg'] ?? 'Failed to toggle like'
            : 'Failed to toggle like';
        throw Exception(errorMsg);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleBookmark(String postId, bool isBookmarked) async {
    final endpoint = isBookmarked ? 'unbookmark' : 'bookmark';
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please log in.');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/posts/$endpoint/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      if (response.statusCode != 200) {
        final responseBody = jsonDecode(response.body);
        final errorMsg = responseBody is Map
            ? responseBody['msg'] ?? 'Failed to toggle bookmark'
            : 'Failed to toggle bookmark';
        throw Exception(errorMsg);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Post>> getBookmarkedPosts() async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please log in.');
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users/me/bookmarks'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody is Map<String, dynamic> && responseBody['success'] == true) {
          final List<dynamic> posts = responseBody['data'] ?? [];
          return posts.map((post) => Post.fromJson(post)).toList();
        } else {
          throw Exception(responseBody['msg'] ?? 'Invalid response format');
        }
      } else if (response.statusCode == 401) {
        await clearToken();
        throw Exception('Session expired. Please log in again.');
      } else {
        final errorMsg = responseBody is Map
            ? responseBody['msg'] ?? 'Failed to load bookmarks'
            : 'Failed to load bookmarks';
        throw Exception(errorMsg);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getUser(String userId) async {
    try {
      if (kDebugMode) {
        print('🔍 Fetching user with ID: $userId');
        print('🌐 Making request to: $baseUrl/users/$userId');
      }
      
      final token = await _getToken();
      if (kDebugMode) {
        print('🔑 Using token: ${token != null ? 'Token exists' : 'No token found'}');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'x-auth-token': token,
        },
      );

      if (kDebugMode) {
        print('📥 Response status: ${response.statusCode}');
        print('📦 Response body: ${response.body}');
      }

      final responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        try {
          if (responseBody is Map<String, dynamic> && responseBody['success'] == true) {
            if (responseBody['data'] == null) {
              throw Exception('User data is null in the response');
            }
            return User.fromJson(responseBody['data']);
          } else {
            final errorMsg = responseBody['msg'] ?? 'Invalid response format';
            if (kDebugMode) {
              print('❌ Error response: $errorMsg');
            }
            throw Exception(errorMsg);
          }
        } catch (e) {
          if (kDebugMode) {
            print('❌ Error parsing user data: $e');
          }
          throw Exception('Failed to parse user data: $e');
        }
      } else if (response.statusCode == 401) {
        // print('Authentication required');
        throw Exception(responseBody is Map 
            ? responseBody['msg'] ?? 'Authentication required. Please log in.'
            : 'Authentication required. Please log in.');
      } else if (response.statusCode == 404) {
        // print('User not found');
        throw Exception(responseBody is Map 
            ? responseBody['msg'] ?? 'User not found'
            : 'User not found');
      } else {
        final errorMsg = responseBody is Map 
            ? responseBody['msg'] ?? 'Failed to load user'
            : 'Failed to load user';
        // print('Server error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      // print('Exception in getUser: $e');
      rethrow;
    }
  }

  Future<List<comment_model.Comment>> getComments(String postId) async {
    try {
      final token = await _getToken();
      
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId/comments'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'x-auth-token': token,
        },
      );

      // print('Get comments response: ${response.statusCode}');
      // print('Response body: ${response.body}');

      final responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (responseBody is Map<String, dynamic> && responseBody['success'] == true) {
          final List<dynamic> comments = responseBody['data'] ?? [];
          return comments.map((comment) => comment_model.Comment.fromJson(comment)).toList();
        } else {
          throw Exception(responseBody['msg'] ?? 'Invalid response format');
        }
      } else if (response.statusCode == 401) {
        if (token != null) await clearToken();
        throw Exception('Authentication required. Please log in.');
      } else if (response.statusCode == 404) {
        throw Exception('Post not found');
      } else {
        final errorMsg = responseBody is Map 
            ? responseBody['msg'] ?? 'Failed to load comments'
            : 'Failed to load comments';
        throw Exception(errorMsg);
      }
    } catch (e) {
      // print('Exception in getComments: $e');
      rethrow;
    }
  }

  Future<comment_model.Comment> addComment({
    required String postId,
    required String text,
    String? parentCommentId,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please log in.');
      }

      final Map<String, dynamic> body = {'text': text};
      if (parentCommentId != null) {
        body['parentCommentId'] = parentCommentId;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/posts/comment/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(body),
      );

      // print('Add comment response: ${response.statusCode}');
      // print('Response body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (responseBody is Map<String, dynamic> && responseBody['success'] == true) {
          return comment_model.Comment.fromJson(responseBody['data']);
        } else {
          throw Exception(responseBody['msg'] ?? 'Invalid response format');
        }
      } else if (response.statusCode == 401) {
        await clearToken();
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 404) {
        throw Exception('Post not found');
      } else {
        final errorMsg = responseBody is Map 
            ? responseBody['msg'] ?? 'Failed to add comment'
            : 'Failed to add comment';
        throw Exception(errorMsg);
      }
    } catch (e) {
      // print('Exception in addComment: $e');
      rethrow;
    }
  }

  Future<List<Post>> getPostsByUser(String userId) async {
    try {
      // print('Fetching posts for user ID: $userId');
      final token = await _getToken();
      
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please log in.');
      }
      
      final response = await http.get(
        Uri.parse('$baseUrl/posts/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      // print('Posts response status: ${response.statusCode}');
      // print('Posts response body: ${response.body}');

      final responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (responseBody is Map<String, dynamic> && responseBody['success'] == true) {
          final List<dynamic> posts = responseBody['data'] ?? [];
          return posts.map((post) => Post.fromJson(post)).toList();
        } else {
          throw Exception(responseBody['msg'] ?? 'Invalid response format');
        }
      } else if (response.statusCode == 401) {
        // print('Authentication failed - invalid or expired token');
        await clearToken();
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 404) {
        // print('No posts found for user');
        return [];
      } else {
        final errorMsg = responseBody is Map 
            ? responseBody['msg'] ?? 'Failed to load posts'
            : 'Failed to load posts';
        // print('Server error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      // print('Exception in getPostsByUser: $e');
      rethrow;
    }
  }

  Future<User> updateProfile({
    String? username,
    String? bio,
    String? fullName,
    String? location,
    String? website,
    String? profileImageUrl,
    bool? isPrivate,
  }) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Not authenticated. Please log in again.');
      }

      // Only include fields that are not null in the request
      final Map<String, dynamic> updateData = {};
      if (username != null) updateData['username'] = username;
      if (bio != null) updateData['bio'] = bio;
      if (fullName != null) updateData['fullName'] = fullName;
      if (location != null) updateData['location'] = location;
      if (website != null) updateData['website'] = website;
      if (profileImageUrl != null) updateData['profileImageUrl'] = profileImageUrl;
      if (isPrivate != null) updateData['isPrivate'] = isPrivate;

      // print('Updating profile with data: $updateData');
      
      final response = await http.put(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(updateData),
      );

      // print('Update profile response: ${response.statusCode}');
      // print('Response body: ${response.body}');

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseBody is Map<String, dynamic> && responseBody['success'] == true) {
          return User.fromJson(responseBody['data']);
        } else {
          throw Exception(responseBody['msg'] ?? 'Invalid response format');
        }
      } else if (response.statusCode == 400) {
        // Handle validation errors
        final errorMsg = responseBody is Map 
            ? responseBody['msg'] ?? 'Validation error'
            : 'Validation error';
        
        if (responseBody is Map && responseBody['errors'] is List) {
          throw Exception('Validation failed: ${responseBody['errors'].join(', ')}');
        }
        
        throw Exception(errorMsg);
      } else if (response.statusCode == 401) {
        await clearToken();
        throw Exception('Session expired. Please log in again.');
      } else {
        final errorMsg = responseBody is Map 
            ? responseBody['msg'] ?? 'Failed to update profile'
            : 'Failed to update profile';
        throw Exception(errorMsg);
      }
    } catch (e) {
      // print('Exception in updateProfile: $e');
      rethrow;
    }
  }

  Future<void> follow(String userId) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please log in.');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/users/follow/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      // print('Follow user response: ${response.statusCode}');

      if (response.statusCode != 200) {
        final responseBody = jsonDecode(response.body);
        final errorMsg = responseBody is Map 
            ? responseBody['msg'] ?? 'Failed to follow user'
            : 'Failed to follow user';
        throw Exception(errorMsg);
      }
    } catch (e) {
      // print('Exception in follow: $e');
      rethrow;
    }
  }

  Future<void> unfollow(String userId) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please log in.');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/users/unfollow/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      // print('Unfollow user response: ${response.statusCode}');

      if (response.statusCode != 200) {
        final responseBody = jsonDecode(response.body);
        final errorMsg = responseBody is Map 
            ? responseBody['msg'] ?? 'Failed to unfollow user'
            : 'Failed to unfollow user';
        throw Exception(errorMsg);
      }
    } catch (e) {
      // print('Exception in unfollow: $e');
      rethrow;
    }
  }
}
