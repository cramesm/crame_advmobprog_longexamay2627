import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../constants.dart';
import '../models/user.dart';
import '../providers/theme_provider.dart';
import '../services/user_service.dart';
import '../widgets/custom_font.dart';

// Enhancement 2: Settings screen for user preferences and Sign Out action
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();
  User? _currentUser;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  // Enhancement 2: Loads authenticated user profile info
  Future<void> _loadUser() async {
    final user = await _userService.getUserData();
    if (mounted) {
      setState(() {
        _currentUser = user;
        _isLoadingUser = false;
      });
    }
  }

  // Enhancement 2: Confirms sign out, clears session, and navigates to Login
  Future<void> _confirmSignOut() async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      await _userService.logout();
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return Scaffold(
      appBar: AppBar(
        title: CustomFont(
          text: 'Settings',
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.r),
        children: [
          // 1. Account Info Card
          if (_isLoadingUser)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_currentUser != null) ...[
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30.r,
                      backgroundColor: FB_LIGHT_PRIMARY.withValues(alpha: 0.2),
                      backgroundImage: _currentUser!.image.isNotEmpty
                          ? CachedNetworkImageProvider(_currentUser!.image)
                          : null,
                      child: _currentUser!.image.isEmpty
                          ? Icon(Icons.person, size: 30.r, color: FB_PRIMARY)
                          : null,
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomFont(
                            text: _currentUser!.fullName,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '@${_currentUser!.username}',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: Colors.grey,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            _currentUser!.email,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // 2. User Preferences (Theme Toggle)
          CustomFont(
            text: 'Preferences',
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
          SizedBox(height: 8.h),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  secondary: Icon(
                    isDark ? Icons.dark_mode : Icons.light_mode,
                    color: isDark ? Colors.amber : Colors.indigo,
                  ),
                  title: CustomFont(
                    text: 'Dark Mode',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  subtitle: CustomFont(
                    text: isDark
                        ? 'Dark theme is currently active'
                        : 'Light theme is currently active',
                    fontSize: 12.sp,
                    color: Colors.grey,
                  ),
                  value: isDark,
                  onChanged: (bool value) {
                    themeProvider.setDarkTheme(value);
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 24.h),

          // 3. Sign Out Button (Enhancement 2)
          CustomFont(
            text: 'Account',
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
          SizedBox(height: 8.h),
          Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.redAccent),
              title: Text(
                'Sign Out',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text('Sign out and return to the login screen'),
              onTap: _confirmSignOut,
            ),
          ),
        ],
      ),
    );
  }
}