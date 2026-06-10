import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../state/matches_provider.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import '../widgets/empty_state.dart';
import '../widgets/match_tile.dart';
import 'chat_screen.dart';

/// Matches tab: people who liked you back.
class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final matches = context.watch<MatchesProvider>().matches;

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          _buildHeader(matches.length),
          Expanded(
            child:
                matches.isEmpty
                    ? const EmptyState(
                      icon: Icons.favorite_rounded,
                      title: 'No matches yet',
                      message:
                          'Like someone in Discover and wait\nfor them to match back.',
                    )
                    : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        Spacing.lg,
                        Spacing.lg,
                        Spacing.lg,
                        Spacing.navClearance,
                      ),
                      itemCount: matches.length,
                      separatorBuilder:
                          (ctx, i) => const SizedBox(height: Spacing.md),
                      itemBuilder: (context, index) {
                        final match = matches[index];
                        return MatchTile(
                          match: match,
                          animationIndex: index,
                          onTap:
                              () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ChatScreen(match: match),
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

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Spacing.gutter,
        Spacing.xl,
        Spacing.gutter,
        Spacing.md,
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Matches',
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: -0.8,
                ),
              ),
              Text(
                'People who liked you back',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (count > 0)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(Radii.sm),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                '$count',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: Motion.entrance);
  }
}
