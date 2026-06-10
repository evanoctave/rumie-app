import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../domain/entities/lifestyle.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// "Verified student" / "Verified listing" trust badge.
class VerificationBadge extends StatelessWidget {
  final VerificationStatus status;

  /// Overrides the label (e.g. "Verified listing").
  final String? label;
  final bool compact;

  const VerificationBadge({
    super.key,
    this.status = VerificationStatus.verifiedStudent,
    this.label,
    this.compact = false,
  });

  const VerificationBadge.listing({super.key, this.compact = false})
    : status = VerificationStatus.verifiedStudent,
      label = 'Verified listing';

  @override
  Widget build(BuildContext context) {
    final verified = status == VerificationStatus.verifiedStudent;
    final color = verified ? AppColors.green : AppColors.yellow;
    final text = label ?? status.label;
    final icon = verified ? Icons.verified_rounded : Icons.schedule_rounded;

    if (compact) {
      return Icon(icon, color: color, size: 18);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(AppColors.isDark ? 45 : 26),
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.dmSans(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 11.5,
            ),
          ),
        ],
      ),
    );
  }
}
