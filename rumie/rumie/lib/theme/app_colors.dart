import 'package:flutter/material.dart';

/// Central color palette for the app. Keep all color literals here so
/// you can re-theme the whole app from one place.
class AppColors {
  static const Color purple = Color(0xFF8B5CF6);
  static const Color pink = Color(0xFFEC4899);
  static const Color softPink = Color(0xFFFCE7F3);
  static const Color softPurple = Color(0xFFEDE9FE);
  static const Color darkText = Color(0xFF1F2937);
  static const Color gray = Color(0xFF6B7280);
  static const Color background = Color(0xFFFAF5FF);

  /// Primary brand gradient used across cards, avatars, and accents.
  static const LinearGradient brandGradient = LinearGradient(
    colors: [pink, purple],
  );
}
