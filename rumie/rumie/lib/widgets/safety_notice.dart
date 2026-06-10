import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Inline trust & safety reminder banner.
class SafetyNotice extends StatelessWidget {
  final String message;
  final VoidCallback? onTap;

  const SafetyNotice({super.key, required this.message, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: Spacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.blue.withAlpha(AppColors.isDark ? 40 : 22),
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: AppColors.blue.withAlpha(70)),
        ),
        child: Row(
          children: [
            const Icon(Icons.shield_rounded, color: AppColors.blue, size: 18),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.dmSans(
                  color: AppColors.text,
                  fontSize: 12.5,
                  height: 1.45,
                ),
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
