import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Theme mode flag (set by ThemeProvider) ────────────────────────────────
  static bool isDark = false;

  // ── Backgrounds (adaptive) ────────────────────────────────────────────────
  static Color get background =>
      isDark ? const Color(0xFF0D0B1A) : const Color(0xFFFAF9F7);
  static Color get surface =>
      isDark ? const Color(0xFF16132B) : const Color(0xFFFFFFFF);
  static Color get cardBg =>
      isDark ? const Color(0xFF16132B) : const Color(0xFFFFFFFF);
  static Color get border =>
      isDark ? const Color(0xFF2D2947) : const Color(0xFFEAE5F5);
  static Color get softPurple =>
      isDark ? const Color(0xFF1E1440) : const Color(0xFFEDE9FE);
  static Color get borderBright =>
      isDark ? const Color(0xFF5B3FA8) : const Color(0xFFD8B4FE);

  // ── Text (adaptive) ───────────────────────────────────────────────────────
  static Color get text =>
      isDark ? const Color(0xFFF0EEFF) : const Color(0xFF0F0F23);
  static Color get textSecondary =>
      isDark ? const Color(0xFF9CA3AF) : const Color(0xFF64748B);
  static Color get gray =>
      isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);

  // ── Brand Purple (Primary) — stays constant ───────────────────────────────
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFF8B5CF6);

  // ── Brand Green (Secondary) ───────────────────────────────────────────────
  static const Color green = Color(0xFF10B981);
  static const Color greenDark = Color(0xFF059669);
  static const Color softGreen = Color(0xFFD1FAE5);

  // ── Accent Pink ───────────────────────────────────────────────────────────
  static const Color pink = Color(0xFFEC4899);
  static const Color softPink = Color(0xFFFCE7F3);

  // ── Accent Yellow ─────────────────────────────────────────────────────────
  static const Color yellow = Color(0xFFF59E0B);
  static const Color softYellow = Color(0xFFFEF3C7);

  // ── Accent Orange ─────────────────────────────────────────────────────────
  static const Color orange = Color(0xFFF97316);
  static const Color softOrange = Color(0xFFFFEDD5);

  // ── Accent Blue ───────────────────────────────────────────────────────────
  static const Color blue = Color(0xFF3B82F6);
  static const Color softBlue = Color(0xFFEFF6FF);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color red = Color(0xFFEF4444);
  static const Color softRed = Color(0xFFFEE2E2);
  static const Color teal = Color(0xFF14B8A6);

  // ── Legacy aliases ────────────────────────────────────────────────────────
  static const Color accent = primaryLight;
  static const Color darkGreen = greenDark;
  static Color get cardCream => cardBg;
  static Color get darkText => text;
  static const Color secondary = primary;
  static const Color mauve = primary;
  static const Color darkMauve = Color(0xFF6D28D9);
  static const Color sage = green;
  static const Color peach = orange;

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGreenGradient = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient likeGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nopeGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient peachGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF7C3AED).withAlpha(isDark ? 30 : 14),
      blurRadius: 28,
      offset: const Offset(0, 10),
      spreadRadius: -6,
    ),
    BoxShadow(
      color: Colors.black.withAlpha(isDark ? 40 : 6),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: const Color(0xFF7C3AED).withAlpha(isDark ? 40 : 20),
      blurRadius: 36,
      offset: const Offset(0, 14),
      spreadRadius: -8,
    ),
    BoxShadow(
      color: Colors.black.withAlpha(isDark ? 60 : 10),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get navShadow => [
    BoxShadow(
      color: const Color(0xFF7C3AED).withAlpha(isDark ? 40 : 18),
      blurRadius: 40,
      spreadRadius: 0,
      offset: const Offset(0, -6),
    ),
    BoxShadow(
      color: Colors.black.withAlpha(isDark ? 60 : 8),
      blurRadius: 20,
      offset: const Offset(0, -2),
    ),
  ];

  static List<BoxShadow> get buttonShadow => [
    BoxShadow(
      color: const Color(0xFF7C3AED).withAlpha(50),
      blurRadius: 20,
      offset: const Offset(0, 8),
      spreadRadius: -4,
    ),
  ];
}
