import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants.dart';
import '../models/user.dart';

// Enhancement 1 & 2: Handles user authentication, local session storage, and logout
class UserService {
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // Enhancement 1: Authenticates user against DummyJSON /auth/login and saves session
  Future<User> login(String username, String password) async {
    final uri = Uri.parse('$host/auth/login');
    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username.trim(),
          'password': password.trim(),
          'expiresInMins': 60,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final user = User.fromJson(data);
        await saveUserData(user);
        return user;
      } else {
        String errorMessage = 'Invalid username or password';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map && errorData['message'] != null) {
            errorMessage = errorData['message'].toString();
          }
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Connection error: $e');
    }
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
