import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/post.dart';

// Enhancement 2: Fetches feed posts and user-specific posts from DummyJSON API
class PostService {
  // Fetches general feed posts with pagination
  Future<List<Post>> getPosts({int limit = 30, int skip = 0}) async {
    final uri = Uri.parse('$host/posts?limit=$limit&skip=$skip');
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List postsJson = data['posts'] ?? [];
      return postsJson.map((p) => Post.fromJson(p)).toList();
    } else {
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }

  // Enhancement 2: Fetches posts authored by a specific user ID for ProfileScreen
  Future<List<Post>> getPostsByUserId(int userId) async {
    final uri = Uri.parse('$host/posts/user/$userId');
    final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List postsJson = data['posts'] ?? [];
      return postsJson.map((p) => Post.fromJson(p)).toList();
    } else {
      // Fallback endpoint if primary fails
      final fallbackUri = Uri.parse('$host/users/$userId/posts');
      final fallbackResponse = await http.get(fallbackUri, headers: {'Content-Type': 'application/json'});
      if (fallbackResponse.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(fallbackResponse.body);
        final List postsJson = data['posts'] ?? [];
        return postsJson.map((p) => Post.fromJson(p)).toList();
      }
      throw Exception('Failed to load posts for user $userId: ${response.statusCode}');
    }
  }
}