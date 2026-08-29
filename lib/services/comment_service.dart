import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants.dart';
import '../models/comment.dart';

// Enhancement 3: Handles fetching and creating comments via DummyJSON Comments API
class CommentService {
  // Enhancement 3: Fetches comments for a specific post by postId
  Future<List<Comment>> getCommentsByPostId(int postId) async {
    final uri = Uri.parse('$host/comments/post/$postId');
    try {
      final response = await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List commentsJson = data['comments'] ?? [];
        return commentsJson.map((c) => Comment.fromJson(c)).toList();
      } else {
        // Fallback endpoint
        final fallbackUri = Uri.parse('$host/posts/$postId/comments');
        final fallbackResponse = await http.get(fallbackUri, headers: {'Content-Type': 'application/json'});
        if (fallbackResponse.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(fallbackResponse.body);
          final List commentsJson = data['comments'] ?? [];
          return commentsJson.map((c) => Comment.fromJson(c)).toList();
        }
        return [];
      }
    } catch (_) {
      return [];
    }
  }

  // Enhancement 3: Submits a new comment to DummyJSON /comments/add
  Future<Comment> addComment({
    required int postId,
    required String body,
    required int userId,
  }) async {
    final uri = Uri.parse('$host/comments/add');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'body': body.trim(),
          'postId': postId,
          'userId': userId,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Comment.fromJson(data);
      } else {
        throw Exception('Failed to add comment: ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Connection error adding comment: $e');
    }
  }
}
