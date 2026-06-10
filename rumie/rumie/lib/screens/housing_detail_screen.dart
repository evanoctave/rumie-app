import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/utils/profile_styles.dart';
import '../domain/entities/housing_listing.dart';
import '../state/group_provider.dart';
import '../state/saved_provider.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import '../widgets/rumie_button.dart';
import '../widgets/rumie_card.dart';
import '../widgets/rumie_chip.dart';
import '../widgets/safety_notice.dart';
import '../widgets/save_button.dart';
import '../widgets/section_header.dart';
import '../widgets/verification_badge.dart';
import 'safety_center_screen.dart';

/// Full listing detail: hero, key facts, amenities, safety, group CTAs.
class HousingDetailScreen extends StatelessWidget {
  final HousingListing listing;

  const HousingDetailScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    final saved = context.watch<SavedProvider>().isListingSaved(listing.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildHero(context, saved),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.gutter,
                Spacing.xl,
                Spacing.gutter,
                40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleBlock(),
                  const SizedBox(height: Spacing.lg),
                  _buildKeyFacts(),
                  const SizedBox(height: Spacing.xxl),
                  if (listing.description.isNotEmpty) ...[
                    const SectionHeader(title: 'About this place'),
                    const SizedBox(height: Spacing.md),
                    Text(
                      listing.description,
                      style: GoogleFonts.dmSans(
                        fontSize: 14.5,
                        color: AppColors.text,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: Spacing.xxl),
                  ],
                  const SectionHeader(title: 'Amenities'),
                  const SizedBox(height: Spacing.md),
                  Wrap(
                    spacing: Spacing.sm,
                    runSpacing: Spacing.sm,
                    children: [
                      for (final a in listing.amenities)
                        RumieChip(label: a, color: AppColors.teal),
                      RumieChip(
                        label: listing.petPolicy,
                        color: AppColors.orange,
                      ),
                      RumieChip(
                        label: '${listing.leaseLengthMonths}-month lease',
                        color: AppColors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xxl),
                  const SectionHeader(title: 'Location'),
                  const SizedBox(height: Spacing.md),
                  _buildMapPlaceholder(),
                  const SizedBox(height: Spacing.xxl),
                  const SectionHeader(title: 'Trust & safety'),
                  const SizedBox(height: Spacing.md),
                  _buildSafety(context),
                  const SizedBox(height: Spacing.xxl),
                  const SectionHeader(title: 'Live here together'),
                  const SizedBox(height: Spacing.md),
                  RumieCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Need roommates for this place?',
                          style: GoogleFonts.dmSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Start a group around this listing and Rumie will surface compatible roommates who fit the budget and move-in date.',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: Spacing.lg),
                        RumieButton(
                          label: 'Create group for this listing',
                          icon: Icons.group_add_rounded,
                          variant: RumieButtonVariant.secondary,
                          onTap: () async {
                            await context.read<GroupProvider>().attachListing(
                              listing.id,
                            );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Listing attached to your group 🎉',
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Spacing.xxl),
                  RumieButton(
                    label: 'Contact about this place',
                    icon: Icons.chat_bubble_rounded,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Applications open once the landlord connects — coming soon',
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, bool saved) {
    final gradient = ProfileStyles.gradientFor(listing.id);
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.surface,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: _circleButton(
          context,
          Icons.arrow_back_rounded,
          () => Navigator.pop(context),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: Spacing.md, top: 8, bottom: 8),
          child: SaveButton(
            saved: saved,
            onToggle:
                () => context.read<SavedProvider>().toggleListing(listing.id),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: DecoratedBox(
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
              size: 80,
            ).animate().scale(duration: Motion.slow, curve: Motion.spring),
          ),
        ),
      ),
    );
  }

  Widget _circleButton(
    BuildContext context,
    IconData icon,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface.withAlpha(230),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.text, size: 20),
      ),
    );
  }

  Widget _buildTitleBlock() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                listing.title,
                style: GoogleFonts.dmSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 15,
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${listing.addressLabel} · ${listing.neighborhood}, ${listing.city}',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Spacing.md),
        Row(
          children: [
            Text(
              '\$${listing.priceMonthly}',
              style: GoogleFonts.dmSans(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: -0.6,
              ),
            ),
            Text(
              ' /month',
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            if (listing.verified) const VerificationBadge.listing(),
          ],
        ),
      ],
    );
  }

  Widget _buildKeyFacts() {
    final facts = [
      (Icons.bed_rounded, listing.bedsBathsLabel),
      (Icons.meeting_room_rounded, '${listing.availableRooms} open'),
      if (listing.sqft > 0) (Icons.square_foot_rounded, '${listing.sqft} sqft'),
      (Icons.calendar_today_rounded, 'Move in ${listing.moveInLabel}'),
      (Icons.directions_walk_rounded, listing.distanceLabel),
      (Icons.chair_rounded, listing.furnished ? 'Furnished' : 'Unfurnished'),
    ];

    return RumieCard(
      child: Wrap(
        spacing: Spacing.xl,
        runSpacing: Spacing.lg,
        children: [
          for (final (icon, label) in facts)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 17, color: AppColors.primary),
                const SizedBox(width: 7),
                Text(
                  label,
                  style: GoogleFonts.dmSans(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: AppColors.softPurple,
        borderRadius: BorderRadius.circular(Radii.card),
        border: Border.all(color: AppColors.border, width: 1.5),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map_rounded, color: AppColors.primary, size: 32),
            const SizedBox(height: Spacing.sm),
            Text(
              '${listing.neighborhood} · near ${listing.nearbyCampus}',
              style: GoogleFonts.dmSans(
                color: AppColors.text,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            Text(
              'Exact address shared after you connect',
              style: GoogleFonts.dmSans(
                color: AppColors.textSecondary,
                fontSize: 11.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafety(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          listing.landlordOrSource,
          style: GoogleFonts.dmSans(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: Spacing.md),
        for (final note in [
          ...listing.safetyNotes,
          'Tour in person or by video before signing anything',
        ]) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.green,
                  size: 16,
                ),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(
                    note,
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: Spacing.sm),
        SafetyNotice(
          message: 'Read our tips for touring and paying safely.',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SafetyCenterScreen()),
              ),
        ),
      ],
    );
  }
}
