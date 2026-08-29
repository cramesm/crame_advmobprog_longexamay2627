// Enhancement 2: Post model representing DummyJSON posts
class Post {
  final int id;
  final int postId;
  final int userId;
  final String title;
  final String body;
  final int likes;
  final int dislikes;
  final int views;
  final List<String> tags;
  final String createdAt;
  final String updatedAt;

  Post({
    required this.id,
    required this.postId,
    required this.userId,
    this.title = '',
    required this.body,
    required this.likes,
    this.dislikes = 0,
    this.views = 0,
    this.tags = const [],
    this.createdAt = '',
    this.updatedAt = '',
  });

  // Deserializes JSON response from DummyJSON posts API
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0,
      postId: json['postId'] ?? json['post_id'] ?? json['id'] ?? 0,
      userId: json['userId'] ?? json['user_id'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      likes: (json['reactions'] is Map && json['reactions']['likes'] != null)
          ? (json['reactions']['likes'] as num).toInt()
          : (json['reactions'] is num)
              ? (json['reactions'] as num).toInt()
              : (json['likes'] as num?)?.toInt() ?? 0,
      dislikes: (json['reactions'] is Map && json['reactions']['dislikes'] != null)
          ? (json['reactions']['dislikes'] as num).toInt()
          : (json['dislikes'] as num?)?.toInt() ?? 0,
      views: (json['views'] as num?)?.toInt() ?? 0,
      tags: (json['tags'] as List?)?.map((t) => t.toString()).toList() ?? [],
      createdAt: json['createdAt'] ?? json['created_at'] ?? '',
      updatedAt: json['updatedAt'] ?? json['updated_at'] ?? '',
    );
  }

  // Serializes Post instance to Map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'title': title,
      'body': body,
      'reactions': {
        'likes': likes,
        'dislikes': dislikes,
      },
      'views': views,
      'tags': tags,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}