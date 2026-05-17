import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds — deep navy
  static const Color background = Color(0xFF0F1923);
  static const Color surface    = Color(0xFF162029);
  static const Color cardBg     = Color(0xFF1C2A37);
  static const Color border     = Color(0xFF233040);
  static const Color borderBright = Color(0xFF2D3F52);

  // Single accent + semantic
  static const Color primary  = Color(0xFF1A8CFF);  // blue accent
  static const Color green    = Color(0xFF22C55E);  // match / success
  static const Color red      = Color(0xFFEF4444);  // pass / danger
  static const Color yellow   = Color(0xFFF59E0B);  // super / featured

  // Compat aliases (used by existing widgets)
  static const Color blue   = primary;
  static const Color orange = Color(0xFFF97316);
  static const Color teal   = Color(0xFF0EA5E9);

  // Soft tinted backgrounds
  static const Color softBlue  = Color(0xFF0D1F30);
  static const Color softGreen = Color(0xFF0D2117);
  static const Color softRed   = Color(0xFF2A1010);

  // Text
  static const Color text          = Color(0xFFF0F4F8);
  static const Color textSecondary = Color(0xFF6B8FAD);
  static const Color darkText      = Color(0xFF0F1923);
  static const Color gray          = Color(0xFF3D5468);

  // Single gradient — used only for primary CTA
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A8CFF), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient likeGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nopeGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Compat shims
  static const Color cardCream     = cardBg;
  static const Color brandGradient = primary;
}
