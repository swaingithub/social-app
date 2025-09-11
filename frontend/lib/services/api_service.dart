import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jivvi/models/comment.dart' as comment_model;
import 'package:jivvi/models/post.dart';
import 'package:jivvi/models/user.dart';

class ApiService {
  late final String baseUrl;

  ApiService() {
    if (Platform.isAndroid) {
      baseUrl = 'http://10.0.2.2:5000/api';
    } else {
      baseUrl = 'http://localhost:5000/api';
    }
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

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
      print('Getting authentication token...');
      final token = await _getToken();
      print('Token: ${token != null ? 'Token exists' : 'Token is null'}');
      
      if (token == null || token.isEmpty) {
        print('No authentication token found');
        throw Exception('Not authenticated. Please log in again.');
      }

      final url = Uri.parse('$baseUrl/users/me');
      print('Making request to: $url');
      
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

        print('Response status: ${response.statusCode}');
        print('Response headers: ${response.headers}');
        
        // Handle empty response body
        if (response.body.isEmpty) {
          throw Exception('Empty response from server');
        }

        dynamic responseBody;
        try {
          responseBody = jsonDecode(response.body);
          print('Parsed response body: $responseBody');
        } catch (e) {
          print('Failed to parse response body: ${response.body}');
          throw Exception('Invalid server response format');
        }
        
        if (response.statusCode == 200) {
          try {
            if (responseBody is Map<String, dynamic>) {
              if (responseBody['success'] == true && responseBody['data'] != null) {
                return User.fromJson(responseBody['data']);
              } else {
                final errorMsg = responseBody['msg'] ?? 'Invalid response format';
                print('API Error: $errorMsg');
                if (responseBody['error'] != null) {
                  print('Additional error info: ${responseBody['error']}');
                }
                throw Exception(errorMsg);
              }
            } else {
              throw Exception('Unexpected response format');
            }
          } catch (e) {
            print('Error parsing user data: $e');
            throw Exception('Failed to parse user data: $e');
          }
        } else if (response.statusCode == 401) {
          print('Authentication failed - invalid or expired token');
          await clearToken();
          throw Exception(responseBody is Map 
              ? responseBody['msg'] ?? 'Session expired. Please log in again.'
              : 'Session expired. Please log in again.');
        } else {
          final errorMsg = responseBody is Map 
              ? responseBody['msg'] ?? 'Failed to get user (Status: ${response.statusCode})'
              : 'Failed to get user (Status: ${response.statusCode})';
          print('Server error: $errorMsg');
          throw Exception(errorMsg);
        }
      } on http.ClientException catch (e) {
        if (e.message.contains('timed out')) {
          print('Request timed out');
          throw Exception('Request timed out. Please check your connection and try again.');
        }
        print('HTTP Client Exception: $e');
        throw Exception('Network error: ${e.message}');
      } on FormatException catch (e) {
        print('Format Exception: $e');
        throw Exception('Invalid server response format');
      } catch (e) {
        print('Unexpected error in getMe: $e');
        throw Exception('An unexpected error occurred. Please try again.');
      }
    } catch (e) {
      print('Exception in getMe: $e');
      rethrow;
    }
  }

  Future<List<Post>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Failed to load posts');
    }
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

      print('Create post response: ${response.statusCode}');
      print('Response body: ${response.body}');

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
      print('Exception in createPost: $e');
      rethrow;
    }
  }

  // Like a post
  Future<Post> likePost(String postId) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please log in.');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/posts/like/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      print('Like post response: ${response.statusCode}');
      print('Response body: ${response.body}');

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
            ? responseBody['msg'] ?? 'Failed to like post'
            : 'Failed to like post';
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('Exception in likePost: $e');
      rethrow;
    }
  }

  // Unlike a post
  Future<Post?> unlikePost(String postId) async {
    try {
      final token = await _getToken();
      final response = await http.post(
        Uri.parse('$baseUrl/posts/$postId/unlike'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token ?? '',
        },
      );

      if (response.statusCode == 200) {
        return Post.fromJson(jsonDecode(response.body));
      }
      return null;
    } catch (e) {
      print('Error unliking post: $e');
      return null;
    }
  }

  Future<Post> toggleLike(String postId) async {
    try {
      final token = await _getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Authentication required. Please log in.');
      }

      final response = await http.put(
        Uri.parse('$baseUrl/posts/like/$postId'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
      );

      print('Toggle like response: ${response.statusCode}');
      print('Response body: ${response.body}');

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
      print('Exception in toggleLike: $e');
      rethrow;
    }
  }

  Future<User> getUser(String userId) async {
    try {
      print('Fetching user with ID: $userId');
      print('Making request to: $baseUrl/users/$userId');
      
      final token = await _getToken();
      print('Using token: ${token != null ? 'Token exists' : 'No token'}');
      
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'x-auth-token': token,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        try {
          if (responseBody is Map<String, dynamic> && responseBody['success'] == true) {
            return User.fromJson(responseBody['data']);
          } else {
            throw Exception(responseBody['msg'] ?? 'Invalid response format');
          }
        } catch (e) {
          print('Error parsing user data: $e');
          throw Exception('Failed to parse user data: $e');
        }
      } else if (response.statusCode == 401) {
        print('Authentication required');
        throw Exception(responseBody is Map 
            ? responseBody['msg'] ?? 'Authentication required. Please log in.'
            : 'Authentication required. Please log in.');
      } else if (response.statusCode == 404) {
        print('User not found');
        throw Exception(responseBody is Map 
            ? responseBody['msg'] ?? 'User not found'
            : 'User not found');
      } else {
        final errorMsg = responseBody is Map 
            ? responseBody['msg'] ?? 'Failed to load user'
            : 'Failed to load user';
        print('Server error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('Exception in getUser: $e');
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

      print('Get comments response: ${response.statusCode}');
      print('Response body: ${response.body}');

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
      print('Exception in getComments: $e');
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

      print('Add comment response: ${response.statusCode}');
      print('Response body: ${response.body}');

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
      print('Exception in addComment: $e');
      rethrow;
    }
  }

  Future<List<Post>> getPostsByUser(String userId) async {
    try {
      print('Fetching posts for user ID: $userId');
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

      print('Posts response status: ${response.statusCode}');
      print('Posts response body: ${response.body}');

      final responseBody = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        if (responseBody is Map<String, dynamic> && responseBody['success'] == true) {
          final List<dynamic> posts = responseBody['data'] ?? [];
          return posts.map((post) => Post.fromJson(post)).toList();
        } else {
          throw Exception(responseBody['msg'] ?? 'Invalid response format');
        }
      } else if (response.statusCode == 401) {
        print('Authentication failed - invalid or expired token');
        await clearToken();
        throw Exception('Session expired. Please log in again.');
      } else if (response.statusCode == 404) {
        print('No posts found for user');
        return [];
      } else {
        final errorMsg = responseBody is Map 
            ? responseBody['msg'] ?? 'Failed to load posts'
            : 'Failed to load posts';
        print('Server error: $errorMsg');
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('Exception in getPostsByUser: $e');
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

      print('Updating profile with data: $updateData');
      
      final response = await http.put(
        Uri.parse('$baseUrl/users/me'),
        headers: {
          'Content-Type': 'application/json',
          'x-auth-token': token,
        },
        body: jsonEncode(updateData),
      );

      print('Update profile response: ${response.statusCode}');
      print('Response body: ${response.body}');

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
      print('Exception in updateProfile: $e');
      rethrow;
    }
  }
}
