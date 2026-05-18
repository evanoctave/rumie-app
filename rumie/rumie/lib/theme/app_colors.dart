import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF1FFFA);
  static const Color surface    = Color(0xFFCCFCCB);
  static const Color cardBg     = Color(0xFFFFFFFF);
  static const Color border     = Color(0xFFB8E8C8);

  // ── Brand / Primary ───────────────────────────────────────────────────────
  static const Color primary    = Color(0xFF96E6B3);
  static const Color secondary  = Color(0xFF568259);
  static const Color darkGreen  = Color(0xFF568259);
  static const Color accent     = Color(0xFF96E6B3);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color green  = Color(0xFF96E6B3);
  static const Color red    = Color(0xFFEF4444);
  static const Color yellow = Color(0xFFF59E0B);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color text          = Color(0xFF464E47);
  static const Color textSecondary = Color(0xFF568259);
  static const Color gray          = Color(0xFFA8C4AE);

  // ── Soft tints (badge / chip backgrounds) ────────────────────────────────
  static const Color softGreen  = Color(0xFFDCFCE7);
  static const Color softRed    = Color(0xFFFEE2E2);
  static const Color softBlue   = Color(0xFFDBEAFE);
  static const Color softYellow = Color(0xFFFEF9C3);

  // ── Compat aliases ────────────────────────────────────────────────────────
  static const Color teal      = Color(0xFF0D9488);
  static const Color orange    = yellow;
  static const Color blue      = Color(0xFF3B82F6);
  static const Color pink      = secondary;
  static const Color peach     = yellow;
  static const Color mauve     = secondary;
  static const Color sage      = primary;
  static const Color darkMauve = secondary;

  // Legacy shims
  static const Color borderBright   = Color(0xFF96E6B3);
  static const Color cardCream      = cardBg;
  static const Color brandGradient  = primary;
  static const Color darkText       = text;

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF96E6B3), Color(0xFF568259)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient likeGradient = LinearGradient(
    colors: [Color(0xFF96E6B3), Color(0xFF568259)],
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
}
