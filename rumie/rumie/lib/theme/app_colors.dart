import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFFFFFAEA);
  static const Color cardCream = Color(0xFFFFF8E8);
  static const Color darkText = Color(0xFF101010);

  static const Color pink = Color(0xFFF3A6AD);
  static const Color green = Color(0xFFAEECA8);
  static const Color blue = Color(0xFFA9C9E8);
  static const Color purple = Color(0xFFCDB7F6);
  static const Color yellow = Color(0xFFFFE59D);
  static const Color gray = Color(0xFF666666);

  static const Color softPink = Color(0xFFFFDDE3);
  static const Color softPurple = Color(0xFFE9DDFF);
  static const Color softGreen = Color(0xFFDDF8D8);
  static const Color softBlue = Color(0xFFD9ECFA);

  static const LinearGradient brandGradient = LinearGradient(
    colors: [pink, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
