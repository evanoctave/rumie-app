import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/utils/profile_styles.dart';
import '../domain/entities/housing_listing.dart';
import '../state/saved_provider.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import 'save_button.dart';
import 'verification_badge.dart';

/// Listing card for the Housing tab and Saved tab.
class HousingListingCard extends StatelessWidget {
  final HousingListing listing;
  final VoidCallback onTap;
  final int animationIndex;

  const HousingListingCard({
    super.key,
    required this.listing,
    required this.onTap,
    this.animationIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedProvider>().isListingSaved(listing.id);

    return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(Radii.card),
              border: Border.all(color: AppColors.border, width: 1.5),
              boxShadow: AppColors.cardShadow,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(context, saved),
                Padding(
                  padding: const EdgeInsets.all(Spacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              listing.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                                letterSpacing: -0.3,
                                height: 1.25,
                              ),
                            ),
                          ),
                          const SizedBox(width: Spacing.md),
                          Text(
                            '\$${listing.priceMonthly}',
                            style: GoogleFonts.dmSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              '/mo',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${listing.neighborhood}, ${listing.city} · ${listing.distanceLabel}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: Spacing.md),
                      Row(
                        children: [
                          _fact(Icons.bed_rounded, listing.bedsBathsLabel),
                          const SizedBox(width: Spacing.lg),
                          _fact(
                            Icons.meeting_room_rounded,
                            '${listing.availableRooms} room${listing.availableRooms == 1 ? '' : 's'} open',
                          ),
                          if (listing.furnished) ...[
                            const SizedBox(width: Spacing.lg),
                            _fact(Icons.chair_rounded, 'Furnished'),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(delay: (60 * animationIndex).ms)
        .fadeIn(duration: Motion.entrance)
        .slideY(begin: 0.06, end: 0, curve: Motion.ease);
  }

  Widget _buildHero(BuildContext context, bool saved) {
    final gradient = ProfileStyles.gradientFor(listing.id);
    return SizedBox(
      height: 150,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Icon(
                listing.type == 'House'
                    ? Icons.house_rounded
                    : Icons.apartment_rounded,
                color: Colors.white.withAlpha(170),
                size: 52,
              ),
            ),
          ),
          Positioned(
            top: Spacing.md,
            left: Spacing.md,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(110),
                    borderRadius: BorderRadius.circular(Radii.pill),
                  ),
                  child: Text(
                    listing.type,
                    style: GoogleFonts.dmSans(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (listing.verified) ...[
                  const SizedBox(width: Spacing.sm),
                  const VerificationBadge.listing(),
                ],
              ],
            ),
          ),
          Positioned(
            top: Spacing.md,
            right: Spacing.md,
            child: SaveButton(
              saved: saved,
              onToggle:
                  () => context.read<SavedProvider>().toggleListing(listing.id),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fact(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: AppColors.textSecondary),
        const SizedBox(width: 5),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
