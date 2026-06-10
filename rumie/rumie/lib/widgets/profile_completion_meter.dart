import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Animated profile-completion bar.
class ProfileCompletionMeter extends StatelessWidget {
  /// 0.0–1.0.
  final double completion;

  const ProfileCompletionMeter({super.key, required this.completion});

  @override
  Widget build(BuildContext context) {
    final pct = (completion.clamp(0.0, 1.0) * 100).round();
    final done = pct >= 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              done ? 'Profile complete' : 'Profile $pct% complete',
              style: GoogleFonts.dmSans(
                color: AppColors.text,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            if (!done)
              Text(
                'Finish to match better',
                style: GoogleFonts.dmSans(
                  color: AppColors.textSecondary,
                  fontSize: 11.5,
                ),
              ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(Radii.pill),
          child: Stack(
            children: [
              Container(height: 8, color: AppColors.border),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: completion.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 800),
                curve: Motion.ease,
                builder:
                    (context, value, _) => FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient:
                              done
                                  ? AppColors.likeGradient
                                  : AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(Radii.pill),
                        ),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
