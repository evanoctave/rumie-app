import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Type scale. Bricolage Grotesque for display, DM Sans for everything else.
/// Both are bundled, so there is no network fetch and no font flash.
class AppText {
  AppText._();

  static const String display = 'BricolageGrotesque';
  static const String body = 'DMSans';

  // ── Display (Bricolage) ───────────────────────────────────────────────────
  static TextStyle get hero => TextStyle(
        fontFamily: display,
        fontSize: 44,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.6,
        height: 1.0,
        color: AppColors.text,
      );

  static TextStyle get screenTitle => TextStyle(
        fontFamily: display,
        fontSize: 32,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.1,
        height: 1.05,
        color: AppColors.text,
      );

  static TextStyle get cardName => TextStyle(
        fontFamily: display,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.9,
        height: 1.0,
        color: AppColors.text,
      );

  static TextStyle get sectionTitle => TextStyle(
        fontFamily: display,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        height: 1.15,
        color: AppColors.text,
      );

  static TextStyle get tileTitle => TextStyle(
        fontFamily: display,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.2,
        color: AppColors.text,
      );

  static TextStyle get stat => TextStyle(
        fontFamily: display,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
        height: 1.1,
        color: AppColors.text,
      );

  // ── Body (DM Sans) ────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => TextStyle(
        fontFamily: body,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: AppColors.text,
      );

  static TextStyle get bodyMedium => TextStyle(
        fontFamily: body,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: AppColors.text,
      );

  static TextStyle get secondary => TextStyle(
        fontFamily: body,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: AppColors.textSecondary,
      );

  static TextStyle get caption => TextStyle(
        fontFamily: body,
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: AppColors.textSecondary,
      );

  static TextStyle get label => TextStyle(
        fontFamily: body,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.1,
        color: AppColors.textSecondary,
      );

  static TextStyle get button => TextStyle(
        fontFamily: body,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: -0.1,
        color: AppColors.text,
      );

  static TextStyle get buttonSmall => TextStyle(
        fontFamily: body,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.text,
      );

  static TextStyle get chip => TextStyle(
        fontFamily: body,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.text,
      );

  static TextStyle get micro => TextStyle(
        fontFamily: body,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0.2,
        color: AppColors.textSecondary,
      );
}
