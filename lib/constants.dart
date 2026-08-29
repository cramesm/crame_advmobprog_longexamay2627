// ignore_for_file: constant_identifier_names
import 'package:flutter/material.dart';

const Color FB_PRIMARY = Color(0xFF0D1E4C);
const Color FB_SECONDARY = Color(0xFF26415E);
const Color FB_DARK_PRIMARY = Color(0xFF0B1B32);
const Color FB_LIGHT_PRIMARY = Color(0xFF83A6CE);
const Color FB_TEXT_COLOR_WHITE = Color(0xFFE5C9D7);

class AppConstants {
  AppConstants._();

  static const String host = 'https://dummyjson.com';
}

/// Convenience getter for top-level access to host URL.
String get host => AppConstants.host;