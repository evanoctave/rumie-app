import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Backgrounds ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFF060A06);
  static const Color surface    = Color(0xFF0B130B);
  static const Color cardBg     = Color(0xFF0F1A0F);
  static const Color border     = Color(0xFF1A2E1A);

  // ── Brand / Primary ───────────────────────────────────────────────────────
  static const Color primary   = Color(0xFF22C55E);
  static const Color darkGreen = Color(0xFF16A34A);
  static const Color accent    = Color(0xFF4ADE80);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color green  = primary;
  static const Color red    = Color(0xFFEF4444);
  static const Color yellow = Color(0xFFEAB308);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color text          = Color(0xFFEAF7EA);
  static const Color textSecondary = Color(0xFF4A7050);
  static const Color gray          = Color(0xFF283C28);

  // ── Soft tints (badge / chip backgrounds) ────────────────────────────────
  static const Color softGreen  = Color(0xFF081508);
  static const Color softRed    = Color(0xFF180808);
  static const Color softBlue   = Color(0xFF080F18);
  static const Color softYellow = Color(0xFF181508);

  // ── Compat aliases ────────────────────────────────────────────────────────
  static const Color teal      = Color(0xFF0D9488);
  static const Color orange    = yellow;
  static const Color blue      = primary;
  static const Color pink      = primary;
  static const Color peach     = yellow;
  static const Color mauve     = darkGreen;
  static const Color sage      = primary;
  static const Color darkMauve = darkGreen;

  // Legacy shims
  static const Color borderBright   = Color(0xFF2A4A2A);
  static const Color cardCream      = cardBg;
  static const Color brandGradient  = primary;
  static const Color darkText       = Color(0xFF060A06);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient likeGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient nopeGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient peachGradient = LinearGradient(
    colors: [Color(0xFFEAB308), Color(0xFFCA8A04)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
