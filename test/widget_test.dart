import 'package:flutter_test/flutter_test.dart';
import 'package:crame_longexam/models/user.dart';
import 'package:crame_longexam/models/post.dart';
import 'package:crame_longexam/models/comment.dart';

void main() {
  group('Model Serialization Tests', () {
    test('User model deserialization and serialization', () {
      final userJson = {
        'id': 15,
        'username': 'emilys',
        'email': 'emily.johnson@x.dummyjson.com',
        'firstName': 'Emily',
        'lastName': 'Johnson',
        'gender': 'female',
        'image': 'https://dummyjson.com/icon/emilys/128',
        'accessToken': 'dummy-access-token',
        'refreshToken': 'dummy-refresh-token',
      };

      final user = User.fromJson(userJson);
      expect(user.id, 15);
      expect(user.username, 'emilys');
      expect(user.fullName, 'Emily Johnson');
      expect(user.accessToken, 'dummy-access-token');

      final serialized = user.toJson();
      expect(serialized['id'], 15);
      expect(serialized['username'], 'emilys');
    });

    test('Post model deserialization and reactions parsing', () {
      final postJson = {
        'id': 1,
        'title': 'His mother had always taught him',
        'body': 'His mother had always taught him not to ever think of the past.',
        'userId': 9,
        'tags': ['history', 'american', 'crime'],
        'reactions': {'likes': 192, 'dislikes': 25},
        'views': 305,
      };

      final post = Post.fromJson(postJson);
      expect(post.id, 1);
      expect(post.userId, 9);
      expect(post.likes, 192);
      expect(post.dislikes, 25);
      expect(post.tags.length, 3);
    });

    test('Comment model deserialization and serialization', () {
      final commentJson = {
        'id': 93,
        'body': 'These are fabulous ideas!',
        'postId': 1,
        'likes': 7,
        'user': {
          'id': 190,
          'username': 'leahw',
          'fullName': 'Leah Gutierrez',
          'image': 'https://dummyjson.com/icon/leahw/128',
        },
      };

      final comment = Comment.fromJson(commentJson);
      expect(comment.id, 93);
      expect(comment.body, 'These are fabulous ideas!');
      expect(comment.postId, 1);
      expect(comment.likes, 7);
      expect(comment.user.username, 'leahw');
      expect(comment.user.fullName, 'Leah Gutierrez');
      expect(comment.user.image, 'https://dummyjson.com/icon/leahw/128');

      final serialized = comment.toJson();
      expect(serialized['id'], 93);
      expect(serialized['body'], 'These are fabulous ideas!');
      expect(serialized['user']['image'], 'https://dummyjson.com/icon/leahw/128');
    });
  });
}
