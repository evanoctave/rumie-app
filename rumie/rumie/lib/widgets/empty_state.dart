import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import 'rumie_button.dart';

/// Friendly empty state: icon tile, title, message, optional CTA.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? ctaLabel;
  final VoidCallback? onCta;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.ctaLabel,
    this.onCta,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.softPurple, const Color(0xFFE0D9FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(Radii.xl),
                boxShadow: AppColors.cardShadow,
              ),
              child: Icon(icon, color: AppColors.primary, size: 38),
            ).animate().scale(duration: Motion.slow, curve: Motion.spring),
            const SizedBox(height: Spacing.xxl),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -0.4,
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: Spacing.md),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ).animate().fadeIn(delay: 200.ms),
            if (ctaLabel != null) ...[
              const SizedBox(height: Spacing.xxxl),
              RumieButton(label: ctaLabel!, onTap: onCta, expanded: false)
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .slideY(begin: 0.12, end: 0, curve: Motion.spring),
            ],
          ],
        ),
      ),
    );
  }
}
