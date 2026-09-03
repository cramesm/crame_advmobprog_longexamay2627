import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user.dart';

// Enhancement 1 & 2: Handles user authentication, registration, local session storage, and logout
class UserService {
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _registeredUsersKey = 'registered_users_list';

  // Registers a new user account locally in SharedPreferences
  Future<void> registerUser({
    required String username,
    required String password,
    required String firstName,
    required String lastName,
    required String mobile,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_registeredUsersKey);
    List<dynamic> usersList = [];
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        usersList = jsonDecode(jsonStr);
      } catch (_) {
        usersList = [];
      }
    }

    final newUser = {
      'id': 1000 + usersList.length + 1,
      'username': username.trim(),
      'password': password.trim(),
      'firstName': firstName.trim(),
      'lastName': lastName.trim(),
      'mobile': mobile.trim(),
      'email': '${username.trim().toLowerCase()}@facegram.com',
      'gender': 'unspecified',
      'image': 'https://dummyjson.com/icon/${username.trim().toLowerCase()}/128',
      'accessToken': 'local_token_${username.trim()}',
      'refreshToken': 'local_refresh_${username.trim()}',
    };

    usersList.removeWhere(
      (u) => u is Map && u['username'].toString().toLowerCase() == username.trim().toLowerCase(),
    );
    usersList.add(newUser);

    await prefs.setString(_registeredUsersKey, jsonEncode(usersList));
  }

  // Enhancement 1: Authenticates user against DummyJSON /auth/login and locally registered accounts
  Future<User> login(String username, String password) async {
    final trimmedUsername = username.trim();
    final trimmedPassword = password.trim();

    // 1. Try DummyJSON /auth/login
    try {
      final uri = Uri.parse('$host/auth/login');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': trimmedUsername,
          'password': trimmedPassword,
          'expiresInMins': 60,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final user = User.fromJson(data);
        await saveUserData(user);
        return user;
      }
    } catch (_) {
      // Network error or offline - fallback to local registered users
    }

    // 2. Check locally registered users in SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_registeredUsersKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final List<dynamic> usersList = jsonDecode(jsonStr);
        for (final item in usersList) {
          if (item is Map) {
            final regUsername = item['username']?.toString().toLowerCase();
            final regPassword = item['password']?.toString();
            if (regUsername == trimmedUsername.toLowerCase() && regPassword == trimmedPassword) {
              final user = User(
                id: item['id'] is int ? item['id'] : 1001,
                username: item['username']?.toString() ?? trimmedUsername,
                email: item['email']?.toString() ?? '$trimmedUsername@facegram.com',
                firstName: item['firstName']?.toString() ?? trimmedUsername,
                lastName: item['lastName']?.toString() ?? '',
                gender: item['gender']?.toString() ?? 'unspecified',
                image: item['image']?.toString() ?? 'https://dummyjson.com/icon/$trimmedUsername/128',
                accessToken: item['accessToken']?.toString() ?? 'local_token_$trimmedUsername',
                refreshToken: item['refreshToken']?.toString() ?? 'local_refresh_$trimmedUsername',
              );
              await saveUserData(user);
              return user;
            }
          }
        }
      } catch (_) {}
    }

    throw Exception('Invalid username or password');
  }

  // Enhancement 1: Checks SharedPreferences for active login session
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogged = prefs.getBool(_isLoggedInKey) ?? false;
    final hasUserData = prefs.getString(_userKey) != null;
    return isLogged && hasUserData;
  }

  // Enhancement 1: Retrieves cached User from SharedPreferences
  Future<User?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_userKey);
    if (jsonStr != null && jsonStr.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(jsonStr);
        return User.fromJson(data);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  // Enhancement 1: Saves User JSON and logged-in flag to SharedPreferences
  Future<void> saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Enhancement 2: Clears session data from SharedPreferences on sign out
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
    await prefs.remove(_userKey);
  }
}
