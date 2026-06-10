import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import '../widgets/rumie_button.dart';
import '../widgets/rumie_card.dart';
import '../widgets/section_header.dart';

/// Safety Center: verification, reporting, and meet/tour/pay safely tips.
class SafetyCenterScreen extends StatelessWidget {
  const SafetyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Safety Center',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.text,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          Spacing.gutter,
          Spacing.lg,
          Spacing.gutter,
          40,
        ),
        children: [
          RumieCard(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.likeGradient,
                    borderRadius: BorderRadius.circular(Radii.md),
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: Spacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Built for students, built safe',
                        style: GoogleFonts.dmSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.text,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Verification, reporting, and smart habits keep Rumie trustworthy.',
                        style: GoogleFonts.dmSans(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: Motion.entrance),
          const SizedBox(height: Spacing.xxl),
          const SectionHeader(title: 'Verification'),
          const SizedBox(height: Spacing.md),
          RumieCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tip(
                  Icons.school_rounded,
                  'Verified student badge',
                  'Verify your .edu email to earn the green badge — it tells other students you are who you say you are.',
                ),
                const SizedBox(height: Spacing.lg),
                _tip(
                  Icons.home_work_rounded,
                  'Verified listings',
                  'Listings with the badge had their source identity checked by Rumie. Unverified listings aren\'t bad — just take the extra precautions below.',
                ),
                const SizedBox(height: Spacing.lg),
                RumieButton(
                  label: 'Verify student email',
                  variant: RumieButtonVariant.secondary,
                  icon: Icons.verified_rounded,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Email verification ships with the live API',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xxl),
          const SectionHeader(title: 'Meeting people'),
          const SizedBox(height: Spacing.md),
          RumieCard(
            child: Column(
              children: [
                _tip(
                  Icons.coffee_rounded,
                  'Meet in public first',
                  'A campus café or library beats an apartment for a first meeting. Bring a friend if you can.',
                ),
                const SizedBox(height: Spacing.lg),
                _tip(
                  Icons.lock_rounded,
                  'Share personal info slowly',
                  'Keep chats in Rumie early on. Don\'t share your exact address, class schedule, or financial details with someone you just matched with.',
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xxl),
          const SectionHeader(title: 'Touring & paying'),
          const SizedBox(height: Spacing.md),
          RumieCard(
            child: Column(
              children: [
                _tip(
                  Icons.videocam_rounded,
                  'Tour safely',
                  'See the place in person or over live video before signing. Daylight tours, and tell someone where you\'re going.',
                ),
                const SizedBox(height: Spacing.lg),
                _tip(
                  Icons.payments_rounded,
                  'Never wire money',
                  'No deposits over gift cards, crypto, or wire transfer — ever. Use traceable, trusted payment systems only, and only after a signed lease.',
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.xxl),
          const SectionHeader(title: 'Report & block'),
          const SizedBox(height: Spacing.md),
          RumieCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _tip(
                  Icons.flag_rounded,
                  'Report anything off',
                  'Every profile and listing has a report action. Reports are reviewed and never shown to the person you report.',
                ),
                const SizedBox(height: Spacing.lg),
                _tip(
                  Icons.block_rounded,
                  'Block instantly',
                  'Blocking removes you from each other\'s feeds and conversations immediately.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tip(IconData icon, String title, String body) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.softPurple,
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Icon(icon, color: AppColors.primary, size: 18),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.dmSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.text,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                body,
                style: GoogleFonts.dmSans(
                  fontSize: 12.5,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
