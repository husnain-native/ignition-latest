import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors (Blue)
  static const Color primary = Color(0xFF00BF6F); // Skedda green color
  static const Color primaryDark = Color(0xFF0044CC); // Dark Blue
  static const Color primaryblue = Color.fromARGB(255, 0, 99, 230); // Dark Blue
  static const Color primaryLight = Color(0xFF4D8AFF); // Light Blue

  // Secondary Colors (Yellow)
  static const Color secondary = Color(0xFF666666);
  static const Color secondaryDark = Color(0xFFE6A600); // Dark Yellow
  static const Color secondaryLight = Color(0xFFFFCC40); // Light Yellow

  // Text Colors
  static const Color text = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = Color(0xFF999999); // Light Gray

  // Background Colors
  static const Color background = Color(0xFFFFFFFF); // Pure White
  static const Color surface = Color(0xFFF5F5F5); // Light gray for time slots

  // Status Colors
  static const Color success = Color(0xFF00C853); // Green
  static const Color error = Color(0xFFFF3D00); // Red
  static const Color warning = Color.fromARGB(255, 255, 230, 0); // Using our Yellow
  static const Color info = Color.fromARGB(255, 3, 25, 70); // Using our Blue

  // Other Colors
  static const Color divider = Color(0xFFE0E0E0);
  static const Color shadow = Color(0x1F000000); // Black Shadow

  // Booking status colors
  static const Color available = Color(0xFFE8F5E9); // Light green background
  static const Color booked = Color(0xFFEEEEEE); // Light gray background
  static const Color availableText = Color(0xFF00BF6F); // Green text
  static const Color bookedText = Color(0xFF9E9E9E); // Gray text
}
