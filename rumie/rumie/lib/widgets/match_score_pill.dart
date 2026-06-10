import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Compatibility percentage pill, color-graded by score.
class MatchScorePill extends StatelessWidget {
  final int score;
  final bool large;

  const MatchScorePill({super.key, required this.score, this.large = false});

  LinearGradient get _gradient {
    if (score >= 80) return AppColors.likeGradient;
    if (score >= 60) return AppColors.primaryGradient;
    return AppColors.peachGradient;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 8 : 5,
      ),
      decoration: BoxDecoration(
        gradient: _gradient,
        borderRadius: BorderRadius.circular(Radii.pill),
        boxShadow: [
          BoxShadow(
            color: _gradient.colors.first.withAlpha(70),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt_rounded, color: Colors.white, size: large ? 16 : 13),
          const SizedBox(width: 3),
          Text(
            '$score% match',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: large ? 14 : 12,
            ),
          ),
        ],
      ),
    );
  }
}
