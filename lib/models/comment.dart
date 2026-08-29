// Enhancement 3: Comment and CommentUser models for DummyJSON comments
class CommentUser {
  final int id;
  final String username;
  final String fullName;
  final String image;

  CommentUser({
    required this.id,
    required this.username,
    required this.fullName,
    this.image = '',
  });

  // Deserializes comment author from JSON
  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? json['username'] ?? '',
      image: json['image'] ?? '',
    );
  }

  // Serializes comment author to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'fullName': fullName,
      'image': image,
    };
  }
}

class Comment {
  final int id;
  final String body;
  final int postId;
  int likes;
  final CommentUser user;
  bool isLiked; // Tracks local like button state

  Comment({
    required this.id,
    required this.body,
    required this.postId,
    required this.likes,
    required this.user,
    this.isLiked = false,
  });

  // Deserializes comment from JSON
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] ?? 0,
      body: json['body'] ?? '',
      postId: json['postId'] ?? json['post_id'] ?? 0,
      likes: (json['likes'] as num?)?.toInt() ?? 0,
      user: json['user'] is Map<String, dynamic>
          ? CommentUser.fromJson(json['user'])
          : CommentUser(
              id: json['userId'] ?? 0,
              username: json['user']?.toString() ?? 'User',
              fullName: json['user']?.toString() ?? 'User',
              image: json['image'] ?? '',
            ),
      isLiked: false,
    );
  }

  // Serializes comment to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'body': body,
      'postId': postId,
      'likes': likes,
      'user': user.toJson(),
    };
  }
}