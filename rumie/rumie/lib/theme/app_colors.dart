import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static bool isDark = false;

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static Color get background => isDark ? const Color(0xFF0D0B0A) : const Color(0xFFF2F0EB);
  static Color get surface    => isDark ? const Color(0xFF1A1710) : const Color(0xFFFFFFFF);

  // ── Text ──────────────────────────────────────────────────────────────────
  static Color get text          => isDark ? const Color(0xFFF2F0EB) : const Color(0xFF1A1A1A);
  static Color get textSecondary => isDark ? const Color(0x61F2F0EB) : const Color(0xFF888888);

  // ── Borders ───────────────────────────────────────────────────────────────
  static Color get border     => isDark ? const Color(0x2DF2F0EB) : const Color(0xFF1A1A1A);
  static Color get borderSoft => isDark ? const Color(0x14F2F0EB) : const Color(0xFFDDDAD3);

  // ── Accent purple ─────────────────────────────────────────────────────────
  static Color get accent     => isDark ? const Color(0xFFA78BFA) : const Color(0xFF6D28D9);
  static Color get accentSoft => isDark ? const Color(0x26A78BFA) : const Color(0xFFEDE9FE);

  // ── Chip / button fills ───────────────────────────────────────────────────
  static Color get chipBg         => isDark ? const Color(0xFFF2F0EB) : const Color(0xFF1A1A1A);
  static Color get chipText       => isDark ? const Color(0xFF0D0B0A) : const Color(0xFFF2F0EB);
  static Color get btnPrimary     => isDark ? const Color(0xFFF2F0EB) : const Color(0xFF1A1A1A);
  static Color get btnPrimaryText => isDark ? const Color(0xFF0D0B0A) : const Color(0xFFF2F0EB);

  // ── Value score ───────────────────────────────────────────────────────────
  static Color get scoreHigh   => isDark ? const Color(0xFF4ADE80) : const Color(0xFF1A7A4A);
  static Color get scoreHighBg => isDark ? const Color(0x1F4ADE80) : const Color(0xFFDCFCE7);
  static Color get scoreMid    => isDark ? const Color(0xFFFBBF24) : const Color(0xFFA16207);
  static Color get scoreMidBg  => isDark ? const Color(0x1FFBBF24) : const Color(0xFFFEF9C3);
  static Color get scoreLow    => const Color(0xFFEF4444);
  static Color get scoreLowBg  => isDark ? const Color(0x1FEF4444) : const Color(0xFFFEE2E2);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color red    = Color(0xFFEF4444);
  static const Color green  = Color(0xFF10B981);
  static Color get softRed  => scoreLowBg;

  // ── Legacy aliases ────────────────────────────────────────────────────────
  static Color get primary      => accent;
  static Color get secondary    => accent;
  static Color get primaryLight => accent;
  static Color get cardBg       => surface;
  static Color get darkText     => text;
  static Color get gray         => textSecondary;
  static Color get softPurple   => accentSoft;
  static Color get border2      => border;
  static Color get borderBright => accent;

  static const Color teal       = Color(0xFF14B8A6);
  static const Color blue       = Color(0xFF3B82F6);
  static const Color softBlue   = Color(0xFFEFF6FF);
  static const Color orange     = Color(0xFFF97316);
  static const Color softOrange = Color(0xFFFFEDD5);
  static const Color pink       = Color(0xFFEC4899);
  static const Color softPink   = Color(0xFFFCE7F3);
  static const Color yellow     = Color(0xFFF59E0B);
  static const Color softYellow = Color(0xFFFEF3C7);
  static const Color greenDark  = Color(0xFF059669);
  static const Color softGreen  = Color(0xFFD1FAE5);
  static const Color darkGreen  = Color(0xFF059669);
  static const Color darkMauve  = Color(0xFF6D28D9);
  static const Color mauve      = Color(0xFF7C3AED);
  static const Color sage       = Color(0xFF10B981);
  static const Color peach      = Color(0xFFF97316);

  static List<BoxShadow> get cardShadow => isDark
      ? [BoxShadow(color: Colors.black.withAlpha(60), blurRadius: 12, offset: const Offset(0, 4))]
      : [];

  static List<BoxShadow> get floatingShadow => cardShadow;
  static List<BoxShadow> get navShadow      => [];
  static List<BoxShadow> get buttonShadow   => [];

  static const LinearGradient purpleGreenGradient = LinearGradient(
    colors: [Color(0xFF6D28D9), Color(0xFF10B981)],
  );
  static const LinearGradient likeGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
  );
  static const LinearGradient nopeGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
  );
  static const LinearGradient peachGradient = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
  );
  static const LinearGradient pinkGradient = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFDB2777)],
  );
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6D28D9), Color(0xFF5B21B6)],
  );
}
