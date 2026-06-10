import 'package:flutter/material.dart';

/// Design tokens: spacing, radii, motion durations.
///
/// Colors live in [AppColors] (theme/app_colors.dart). Every screen and
/// widget should pull from these instead of sprinkling magic numbers.
class Spacing {
  Spacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Horizontal screen gutter.
  static const double gutter = 24;

  /// Bottom padding that clears the floating nav bar.
  static const double navClearance = 120;
}

class Radii {
  Radii._();

  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double card = 20;
  static const double sheet = 28;
  static const double pill = 100;
}

class Motion {
  Motion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 250);
  static const Duration slow = Duration(milliseconds: 400);
  static const Duration entrance = Duration(milliseconds: 350);

  static const Curve ease = Curves.easeOutCubic;
  static const Curve spring = Curves.easeOutBack;
}
