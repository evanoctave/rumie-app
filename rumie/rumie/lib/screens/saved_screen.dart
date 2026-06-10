import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../domain/entities/housing_listing.dart';
import '../domain/entities/roommate_candidate.dart';
import '../state/saved_provider.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import '../widgets/empty_state.dart';
import '../widgets/housing_listing_card.dart';
import '../widgets/match_score_pill.dart';
import '../widgets/rumie_avatar.dart';
import '../widgets/rumie_card.dart';
import '../widgets/save_button.dart';
import 'groups_screen.dart';
import 'housing_detail_screen.dart';
import 'roommate_detail_screen.dart';

/// Saved tab: bookmarked roommates and listings, plus the Groups entry.
class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    // Rebuild whenever saves change.
    context.watch<SavedProvider>();

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSegments(),
          Expanded(child: _segment == 0 ? _buildRoommates() : _buildListings()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.gutter,
            Spacing.xl,
            Spacing.gutter,
            Spacing.sm,
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Saved',
                    style: GoogleFonts.dmSans(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                      letterSpacing: -0.8,
                    ),
                  ),
                  Text(
                    'People and places you want to come back to',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const GroupsScreen()),
                    ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.lg,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(Radii.md),
                    boxShadow: AppColors.buttonShadow,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.groups_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'My group',
                        style: GoogleFonts.dmSans(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: Motion.entrance)
        .slideY(begin: -0.15, end: 0, curve: Motion.ease);
  }

  Widget _buildSegments() {
    const labels = ['Roommates', 'Housing'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, 0),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          children: List.generate(labels.length, (i) {
            final selected = _segment == i;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _segment = i);
                },
                child: AnimatedContainer(
                  duration: Motion.normal,
                  curve: Motion.ease,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: selected ? AppColors.primaryGradient : null,
                    borderRadius: BorderRadius.circular(Radii.sm),
                  ),
                  child: Center(
                    child: Text(
                      labels[i],
                      style: GoogleFonts.dmSans(
                        color:
                            selected ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    ).animate().fadeIn(delay: 80.ms, duration: Motion.entrance);
  }

  Widget _buildRoommates() {
    return FutureBuilder<List<RoommateCandidate>>(
      future: context.read<SavedProvider>().savedRoommates(),
      builder: (context, snapshot) {
        final saved = snapshot.data ?? [];
        if (snapshot.connectionState == ConnectionState.done && saved.isEmpty) {
          return const EmptyState(
            icon: Icons.favorite_border_rounded,
            title: 'No saved roommates',
            message:
                'Tap the heart on someone in Discover\nto keep them here for later.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.lg,
            Spacing.lg,
            Spacing.navClearance,
          ),
          itemCount: saved.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: Spacing.md),
          itemBuilder: (context, index) {
            final candidate = saved[index];
            final p = candidate.profile;
            return RumieCard(
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => RoommateDetailScreen(candidate: candidate),
                        ),
                      ),
                  child: Row(
                    children: [
                      RumieAvatar(
                        asset: p.avatarAsset,
                        name: p.name,
                        id: p.id,
                        size: 52,
                      ),
                      const SizedBox(width: Spacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${p.name}, ${p.age}',
                              style: GoogleFonts.dmSans(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${p.school} · ${p.budgetLabel}',
                              style: GoogleFonts.dmSans(
                                fontSize: 12.5,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      MatchScorePill(score: candidate.compatibilityScore),
                      const SizedBox(width: Spacing.sm),
                      SaveButton(
                        saved: true,
                        heart: true,
                        size: 34,
                        onToggle:
                            () => context.read<SavedProvider>().toggleRoommate(
                              p.id,
                            ),
                      ),
                    ],
                  ),
                )
                .animate(delay: (50 * index).ms)
                .fadeIn(duration: Motion.entrance)
                .slideY(begin: 0.06, end: 0, curve: Motion.ease);
          },
        );
      },
    );
  }

  Widget _buildListings() {
    return FutureBuilder<List<HousingListing>>(
      future: context.read<SavedProvider>().savedListings(),
      builder: (context, snapshot) {
        final saved = snapshot.data ?? [];
        if (snapshot.connectionState == ConnectionState.done && saved.isEmpty) {
          return const EmptyState(
            icon: Icons.bookmark_border_rounded,
            title: 'No saved places',
            message:
                'Bookmark listings in Housing and\ncompare them side by side here.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.fromLTRB(
            Spacing.lg,
            Spacing.lg,
            Spacing.lg,
            Spacing.navClearance,
          ),
          itemCount: saved.length,
          separatorBuilder: (ctx, i) => const SizedBox(height: Spacing.lg),
          itemBuilder: (context, index) {
            final listing = saved[index];
            return HousingListingCard(
              listing: listing,
              animationIndex: index,
              onTap:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HousingDetailScreen(listing: listing),
                    ),
                  ),
            );
          },
        );
      },
    );
  }
}
