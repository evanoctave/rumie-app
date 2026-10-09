import 'package:flutter/material.dart';

/// Palette. Warm paper ground, violet-tinted ink, one iris accent.
/// Every token reads through [isDark], which [ThemeProvider] keeps in sync.
class AppColors {
  AppColors._();

  static bool isDark = false;

  // ── Ground & surfaces ─────────────────────────────────────────────────────
  static Color get background => isDark ? const Color(0xFF121117) : const Color(0xFFFAF8F4);
  static Color get surface    => isDark ? const Color(0xFF1B1A21) : const Color(0xFFFFFEFC);
  static Color get surfaceRaised => isDark ? const Color(0xFF23222B) : const Color(0xFFF3F0EA);
  static Color get surfaceSunken => isDark ? const Color(0xFF17161D) : const Color(0xFFF1EEE8);

  // ── Ink ───────────────────────────────────────────────────────────────────
  static Color get text          => isDark ? const Color(0xFFF3F1F6) : const Color(0xFF1B1A22);
  static Color get textSecondary => isDark ? const Color(0xFFA5A2B1) : const Color(0xFF6D6A78);
  static Color get textTertiary  => isDark ? const Color(0xFF6F6C7B) : const Color(0xFFA3A0AD);

  // ── Hairlines ─────────────────────────────────────────────────────────────
  static Color get line       => isDark ? const Color(0xFF2A2932) : const Color(0xFFECE9E3);
  static Color get lineStrong => isDark ? const Color(0xFF35343F) : const Color(0xFFDCD8D0);

  // ── Accent (iris) ─────────────────────────────────────────────────────────
  static Color get accent      => isDark ? const Color(0xFF9D8CFF) : const Color(0xFF6246EA);
  static Color get accentDeep  => isDark ? const Color(0xFFB4A7FF) : const Color(0xFF4F36D6);
  static Color get accentSoft  => isDark ? const Color(0x299D8CFF) : const Color(0xFFECE9FF);
  static Color get onAccent    => isDark ? const Color(0xFF14121F) : const Color(0xFFFBFAFF);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static Color get positive     => isDark ? const Color(0xFF4ADE80) : const Color(0xFF1F9D6B);
  static Color get positiveSoft => isDark ? const Color(0x1F4ADE80) : const Color(0xFFDFF5EA);
  static Color get warning      => isDark ? const Color(0xFFFBBF24) : const Color(0xFFC2830F);
  static Color get warningSoft  => isDark ? const Color(0x1FFBBF24) : const Color(0xFFFBF0D2);
  static Color get danger       => isDark ? const Color(0xFFFF7A7F) : const Color(0xFFDF3F46);
  static Color get dangerSoft   => isDark ? const Color(0x1FFF7A7F) : const Color(0xFFFCE4E5);

  /// Overlay ink used on top of photos (always dark, photo-independent).
  static const Color photoInk = Color(0xFF0E0D14);
  static const Color photoText = Color(0xFFFFFDFA);

  // ── Value score (listings) ────────────────────────────────────────────────
  static Color get scoreHigh   => positive;
  static Color get scoreHighBg => positiveSoft;
  static Color get scoreMid    => warning;
  static Color get scoreMidBg  => warningSoft;
  static Color get scoreLow    => danger;
  static Color get scoreLowBg  => dangerSoft;

  // ── Shadows ───────────────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => isDark
      ? const [BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 10))]
      : const [
          BoxShadow(color: Color(0x14201A30), blurRadius: 28, offset: Offset(0, 12)),
          BoxShadow(color: Color(0x0A201A30), blurRadius: 4, offset: Offset(0, 1)),
        ];

  static List<BoxShadow> get floatingShadow => isDark
      ? const [BoxShadow(color: Color(0x80000000), blurRadius: 32, offset: Offset(0, 14))]
      : const [
          BoxShadow(color: Color(0x1F201A30), blurRadius: 36, offset: Offset(0, 14)),
          BoxShadow(color: Color(0x0F201A30), blurRadius: 6, offset: Offset(0, 2)),
        ];

  static List<BoxShadow> accentGlow([double opacity = 0.35]) => [
        BoxShadow(
          color: accent.withValues(alpha: opacity),
          blurRadius: 28,
          offset: const Offset(0, 10),
        ),
      ];

  // ── Legacy aliases (older call sites) ─────────────────────────────────────
  static Color get border     => lineStrong;
  static Color get borderSoft => line;
  static Color get primary    => accent;
  static Color get secondary  => accent;
  static Color get cardBg     => surface;
  static Color get darkText   => text;
  static Color get gray       => textSecondary;
  static Color get softPurple => accentSoft;
  static Color get red        => danger;
  static Color get green      => positive;
  static Color get softRed    => dangerSoft;
}
