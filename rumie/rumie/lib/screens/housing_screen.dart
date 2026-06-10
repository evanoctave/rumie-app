import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../state/housing_provider.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import '../widgets/empty_state.dart';
import '../widgets/housing_listing_card.dart';
import '../widgets/rumie_chip.dart';
import '../widgets/skeleton_card.dart';
import 'housing_detail_screen.dart';

/// Housing tab: "Find your place."
class HousingScreen extends StatefulWidget {
  const HousingScreen({super.key});

  @override
  State<HousingScreen> createState() => _HousingScreenState();
}

class _HousingScreenState extends State<HousingScreen> {
  @override
  void initState() {
    super.initState();
    final housing = context.read<HousingProvider>();
    if (housing.loading) housing.load();
  }

  @override
  Widget build(BuildContext context) {
    final housing = context.watch<HousingProvider>();

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildFilters(housing),
          Expanded(
            child:
                housing.loading
                    ? _buildLoading()
                    : housing.listings.isEmpty
                    ? const EmptyState(
                      icon: Icons.home_work_rounded,
                      title: 'No places match',
                      message:
                          'Try removing a filter or two —\nnew listings are added all the time.',
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        Spacing.lg,
                        Spacing.lg,
                        Spacing.lg,
                        Spacing.navClearance,
                      ),
                      itemCount: housing.listings.length,
                      separatorBuilder:
                          (ctx, i) => const SizedBox(height: Spacing.lg),
                      itemBuilder: (context, index) {
                        final listing = housing.listings[index];
                        return HousingListingCard(
                          listing: listing,
                          animationIndex: index,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) =>
                                          HousingDetailScreen(listing: listing),
                                ),
                              ),
                        );
                      },
                    ),
          ),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Find your place',
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: -0.8,
                ),
              ),
              Text(
                'Homes that fit you and your roommates',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: Motion.entrance)
        .slideY(begin: -0.15, end: 0, curve: Motion.ease);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.md, Spacing.lg, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.lg,
          vertical: 13,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(Radii.md),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.gray, size: 20),
            const SizedBox(width: Spacing.md),
            Text(
              'Search by neighborhood or campus',
              style: GoogleFonts.dmSans(color: AppColors.gray, fontSize: 14),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 60.ms, duration: Motion.entrance);
  }

  Widget _buildFilters(HousingProvider housing) {
    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: Spacing.md),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
        scrollDirection: Axis.horizontal,
        itemCount: HousingFilter.values.length,
        separatorBuilder: (ctx, i) => const SizedBox(width: Spacing.sm),
        itemBuilder: (context, index) {
          final filter = HousingFilter.values[index];
          return Center(
            child: RumieChip(
              label: filter.label,
              selected: housing.filters.contains(filter),
              onTap: () => housing.toggleFilter(filter),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 100.ms, duration: Motion.entrance);
  }

  Widget _buildLoading() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        Spacing.lg,
        Spacing.lg,
        Spacing.lg,
        Spacing.navClearance,
      ),
      itemCount: 4,
      separatorBuilder: (ctx, i) => const SizedBox(height: Spacing.lg),
      itemBuilder: (ctx, i) => const SkeletonCard(height: 230),
    );
  }
}
