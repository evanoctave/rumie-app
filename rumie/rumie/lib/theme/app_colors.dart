import 'package:flutter/material.dart';

class AppColors {
  // Dark backgrounds
  static const Color background = Color(0xFF0C0C1D);
  static const Color surface = Color(0xFF161628);
  static const Color cardBg = Color(0xFF1E1E38);
  static const Color border = Color(0xFF2A2A4A);
  static const Color borderBright = Color(0xFF3D3D66);

  // Vibrant neon accents
  static const Color pink = Color(0xFFFF3CAC);
  static const Color purple = Color(0xFFA855F7);
  static const Color blue = Color(0xFF38BDF8);
  static const Color green = Color(0xFF4ADE80);
  static const Color yellow = Color(0xFFFBBF24);
  static const Color orange = Color(0xFFFB923C);
  static const Color red = Color(0xFFEF4444);

  // Soft/dimmed for chip backgrounds
  static const Color softPink = Color(0xFF3D1530);
  static const Color softPurple = Color(0xFF2D1A4A);
  static const Color softBlue = Color(0xFF0F2740);
  static const Color softGreen = Color(0xFF0F3020);
  static const Color softYellow = Color(0xFF3D2E00);

  // Text
  static const Color text = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color darkText = Color(0xFF0C0C1D);
  static const Color gray = Color(0xFF64748B);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [pink, purple, blue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkPurpleGradient = LinearGradient(
    colors: [pink, purple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleBlueGradient = LinearGradient(
    colors: [purple, blue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient likeGradient = LinearGradient(
    colors: [Color(0xFF4ADE80), Color(0xFF22C55E)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nopeGradient = LinearGradient(
    colors: [Color(0xFFF87171), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Compat shim — cardCream was the old light card; map to dark card
  static const Color cardCream = cardBg;
}
