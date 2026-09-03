import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/post.dart';

// Enhancement 2: Handles fetching posts via DummyJSON Posts API
class PostService {
  // Enhancement 2: Fetches posts authored by a specific user from DummyJSON
  Future<List<Post>> getPostsByUserId(int userId) async {
    final uri = Uri.parse('$host/posts/user/$userId');
    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List postsJson = data['posts'] ?? [];
        return postsJson.map((p) => Post.fromJson(p)).toList();
      } else {
        throw Exception('Failed to load user posts (${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Connection error loading user posts: $e');
    }
  }

  // Fetches all posts from DummyJSON
  Future<List<Post>> getAllPosts({int limit = 30, int skip = 0}) async {
    final uri = Uri.parse('$host/posts?limit=$limit&skip=$skip');
    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List postsJson = data['posts'] ?? [];
        return postsJson.map((p) => Post.fromJson(p)).toList();
      } else {
        throw Exception('Failed to load posts (${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Connection error loading posts: $e');
    }
  }

  // Fetches a single post by ID
  Future<Post> getPostById(int postId) async {
    final uri = Uri.parse('$host/posts/$postId');
    try {
      final response = await http.get(
        uri,
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Post.fromJson(data);
      } else {
        throw Exception('Failed to load post (${response.statusCode})');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Connection error loading post: $e');
    }
  }
}
