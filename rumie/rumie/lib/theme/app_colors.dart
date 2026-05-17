import 'package:flutter/material.dart';

class AppColors {
  // ── Backgrounds — deep dark mauve ──────────────────────────────────────────
  static const Color background   = Color(0xFF120D11);
  static const Color surface      = Color(0xFF1C1520);
  static const Color cardBg       = Color(0xFF251A23);
  static const Color border       = Color(0xFF3D2B37);
  static const Color borderBright = Color(0xFF52404C);

  // ── Brand palette ─────────────────────────────────────────────────────────
  static const Color peach     = Color(0xFFEFBC9B); // warm peach — money / featured
  static const Color pink      = Color(0xFFEE92C2); // primary pink — CTA / interactive
  static const Color mauve     = Color(0xFF9D6A89); // secondary / muted
  static const Color darkMauve = Color(0xFF725D68); // deeper tone / dividers
  static const Color sage      = Color(0xFFA8B4A5); // sage green — match / success

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color primary = pink;
  static const Color green   = sage;
  static const Color red     = Color(0xFFE05070); // pinkish-red danger / pass
  static const Color yellow  = peach;

  // ── Compat aliases ────────────────────────────────────────────────────────
  static const Color blue   = pink;
  static const Color orange = peach;
  static const Color teal   = mauve;

  // ── Soft tinted backgrounds ───────────────────────────────────────────────
  static const Color softBlue  = Color(0xFF1E1327); // primary-tinted bg
  static const Color softGreen = Color(0xFF141C14); // sage-tinted bg
  static const Color softRed   = Color(0xFF231118); // red-tinted bg

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color text          = Color(0xFFF5EEF5);
  static const Color textSecondary = Color(0xFF9D7A92);
  static const Color darkText      = Color(0xFF120D11);
  static const Color gray          = Color(0xFF5C4458);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFEE92C2), Color(0xFF9D6A89)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient likeGradient = LinearGradient(
    colors: [Color(0xFFA8B4A5), Color(0xFF7A9676)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient nopeGradient = LinearGradient(
    colors: [Color(0xFFE05070), Color(0xFFB03055)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient peachGradient = LinearGradient(
    colors: [Color(0xFFEFBC9B), Color(0xFFD9956A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Compat shims ──────────────────────────────────────────────────────────
  static const Color cardCream     = cardBg;
  static const Color brandGradient = primary;
}
