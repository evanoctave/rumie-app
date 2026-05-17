import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds — dark teal-navy
  static const Color background = Color(0xFF131F24);
  static const Color surface = Color(0xFF1A2B35);
  static const Color cardBg = Color(0xFF22364A);
  static const Color border = Color(0xFF2C4458);
  static const Color borderBright = Color(0xFF3A5A72);

  // Duolingo-inspired palette
  static const Color blue = Color(0xFF1CB0F6);    // primary — discover/chat
  static const Color green = Color(0xFF58CC02);   // match/success
  static const Color orange = Color(0xFFFF9600);  // listings/home
  static const Color red = Color(0xFFFF4B4B);     // pass/danger
  static const Color yellow = Color(0xFFFFC800);  // super/featured
  static const Color teal = Color(0xFF00B8A0);    // secondary accent

  // Soft chip backgrounds (dark tinted)
  static const Color softBlue = Color(0xFF0D2A3D);
  static const Color softGreen = Color(0xFF0D2B10);
  static const Color softOrange = Color(0xFF3D2200);
  static const Color softRed = Color(0xFF3D1010);
  static const Color softYellow = Color(0xFF3D3000);
  static const Color softTeal = Color(0xFF0A2B28);

  // Text
  static const Color text = Color(0xFFEAEFF4);
  static const Color textSecondary = Color(0xFF8BA9BD);
  static const Color darkText = Color(0xFF131F24);
  static const Color gray = Color(0xFF64829A);

  // Gradients
  static const LinearGradient brandGradient = LinearGradient(
    colors: [blue, teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueTealGradient = LinearGradient(
    colors: [blue, teal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient blueGreenGradient = LinearGradient(
    colors: [blue, green],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient likeGradient = LinearGradient(
    colors: [Color(0xFF58CC02), Color(0xFF3DAD00)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nopeGradient = LinearGradient(
    colors: [Color(0xFFFF6B6B), Color(0xFFFF4B4B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Compat shim
  static const Color cardCream = cardBg;
}
