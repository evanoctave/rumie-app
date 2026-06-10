import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../core/utils/profile_styles.dart';
import '../domain/entities/match.dart';
import '../domain/entities/roommate_candidate.dart';
import '../state/matches_provider.dart';
import '../state/saved_provider.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import '../widgets/match_score_pill.dart';
import '../widgets/rumie_avatar.dart';
import '../widgets/rumie_button.dart';
import '../widgets/rumie_card.dart';
import '../widgets/rumie_chip.dart';
import '../widgets/save_button.dart';
import '../widgets/section_header.dart';
import '../widgets/verification_badge.dart';
import 'chat_screen.dart';
import 'safety_center_screen.dart';

/// Full roommate profile: why you match, housing goals, lifestyle, safety.
class RoommateDetailScreen extends StatelessWidget {
  final RoommateCandidate candidate;

  /// Fired when the user likes from here; the host screen handles match flow.
  final VoidCallback? onLike;

  const RoommateDetailScreen({super.key, required this.candidate, this.onLike});

  @override
  Widget build(BuildContext context) {
    final p = candidate.profile;
    final saved = context.watch<SavedProvider>().isRoommateSaved(p.id);
    final matched = context.watch<MatchesProvider>().isMatched(p.id);
    final gradient = ProfileStyles.gradientFor(p.id);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: Colors.white,
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.flag_outlined),
                color: Colors.white,
                tooltip: 'Report or block',
                onPressed: () => _showReportSheet(context, p.name),
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
                  child: RumieAvatar(
                    asset: p.avatarAsset,
                    name: p.name,
                    id: p.id,
                    size: 110,
                  ).animate().scale(
                    duration: Motion.slow,
                    curve: Motion.spring,
                  ),
                ),
              ),
            ),
          ),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${p.name}, ${p.age}',
                          style: GoogleFonts.dmSans(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                            letterSpacing: -0.6,
                          ),
                        ),
                      ),
                      MatchScorePill(
                        score: candidate.compatibilityScore,
                        large: true,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${p.major} · ${p.year} · ${p.school}',
                    style: GoogleFonts.dmSans(
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: Spacing.md),
                  Row(
                    children: [
                      VerificationBadge(status: p.verification),
                      const SizedBox(width: Spacing.sm),
                      RumieChip(
                        label: p.housingIntent.label,
                        color: AppColors.blue,
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xxl),
                  if (candidate.compatibilityReasons.isNotEmpty) ...[
                    const SectionHeader(title: 'Why you match'),
                    const SizedBox(height: Spacing.md),
                    RumieCard(
                      child: Column(
                        children: [
                          for (final reason in candidate.compatibilityReasons)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.favorite_rounded,
                                    color: AppColors.pink,
                                    size: 15,
                                  ),
                                  const SizedBox(width: Spacing.md),
                                  Expanded(
                                    child: Text(
                                      reason,
                                      style: GoogleFonts.dmSans(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.text,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: Spacing.xxl),
                  ],
                  const SectionHeader(title: 'About'),
                  const SizedBox(height: Spacing.md),
                  Text(
                    p.bio,
                    style: GoogleFonts.dmSans(
                      fontSize: 14.5,
                      color: AppColors.text,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: Spacing.xxl),
                  const SectionHeader(title: 'Housing goals'),
                  const SizedBox(height: Spacing.md),
                  RumieCard(
                    child: Column(
                      children: [
                        _goal(Icons.payments_rounded, 'Budget', p.budgetLabel),
                        _goal(
                          Icons.calendar_today_rounded,
                          'Move-in',
                          p.moveInLabel,
                        ),
                        _goal(
                          Icons.location_on_rounded,
                          'Areas',
                          p.preferredNeighborhoods.join(', '),
                        ),
                        _goal(
                          Icons.apartment_rounded,
                          'Housing type',
                          p.housingTypePreference.label,
                        ),
                        _goal(
                          Icons.timelapse_rounded,
                          'Lease',
                          '${p.leaseLengthMonths} months',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Spacing.xxl),
                  const SectionHeader(title: 'Lifestyle'),
                  const SizedBox(height: Spacing.md),
                  Wrap(
                    spacing: Spacing.sm,
                    runSpacing: Spacing.sm,
                    children: [
                      RumieChip(
                        label: p.cleanliness.label,
                        color: ProfileStyles.tagColor(p.cleanliness.label),
                      ),
                      RumieChip(
                        label: p.sleepSchedule.label,
                        color: ProfileStyles.tagColor(p.sleepSchedule.label),
                      ),
                      RumieChip(
                        label: p.noiseTolerance.label,
                        color: ProfileStyles.tagColor(p.noiseTolerance.label),
                      ),
                      RumieChip(
                        label: p.guestPreference.label,
                        color: ProfileStyles.tagColor(p.guestPreference.label),
                      ),
                      RumieChip(
                        label: p.studyHabits.label,
                        color: ProfileStyles.tagColor(p.studyHabits.label),
                      ),
                      RumieChip(
                        label: p.petPreference.label,
                        color: ProfileStyles.tagColor(p.petPreference.label),
                      ),
                      RumieChip(
                        label: p.smokingPreference.label,
                        color: ProfileStyles.tagColor(
                          p.smokingPreference.label,
                        ),
                      ),
                      RumieChip(
                        label: p.drinkingPreference.label,
                        color: ProfileStyles.tagColor(
                          p.drinkingPreference.label,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xxl),
                  const SectionHeader(title: 'Interests'),
                  const SizedBox(height: Spacing.md),
                  Wrap(
                    spacing: Spacing.sm,
                    runSpacing: Spacing.sm,
                    children: [
                      for (final interest in p.interests)
                        RumieChip(
                          label:
                              candidate.sharedInterests.contains(interest)
                                  ? '$interest · shared'
                                  : interest,
                          color:
                              candidate.sharedInterests.contains(interest)
                                  ? AppColors.pink
                                  : ProfileStyles.tagColor(interest),
                          selected: candidate.sharedInterests.contains(
                            interest,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: Spacing.xxxl),
                  Row(
                    children: [
                      SaveButton(
                        saved: saved,
                        heart: true,
                        size: 54,
                        onToggle:
                            () => context.read<SavedProvider>().toggleRoommate(
                              p.id,
                            ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child:
                            matched
                                ? RumieButton(
                                  label: 'Message ${p.name}',
                                  icon: Icons.chat_bubble_rounded,
                                  onTap: () => _openChat(context),
                                )
                                : RumieButton(
                                  label: 'Like ${p.name}',
                                  icon: Icons.favorite_rounded,
                                  onTap:
                                      onLike == null
                                          ? null
                                          : () {
                                            Navigator.pop(context);
                                            onLike!();
                                          },
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.lg),
                  Center(
                    child: GestureDetector(
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SafetyCenterScreen(),
                            ),
                          ),
                      child: Text(
                        'Visit the Safety Center',
                        style: GoogleFonts.dmSans(
                          color: AppColors.textSecondary,
                          fontSize: 12.5,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openChat(BuildContext context) {
    final matches = context.read<MatchesProvider>().matches;
    final match = matches.firstWhere(
      (m) => m.profile.id == candidate.profile.id,
      orElse:
          () => RoommateMatch(
            id: 'match-${candidate.profile.id}',
            profile: candidate.profile,
            matchedAt: DateTime.now(),
            compatibilityScore: candidate.compatibilityScore,
          ),
    );
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ChatScreen(match: match)),
    );
  }

  void _showReportSheet(BuildContext context, String name) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.sheet)),
      ),
      builder:
          (sheetContext) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.xxl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Stay safe',
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: Spacing.sm),
                  Text(
                    'Reports are confidential — $name won\'t know.',
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: Spacing.xl),
                  RumieButton(
                    label: 'Report $name',
                    variant: RumieButtonVariant.danger,
                    icon: Icons.flag_rounded,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Thanks — our team will review this.'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: Spacing.md),
                  RumieButton(
                    label: 'Block $name',
                    variant: RumieButtonVariant.secondary,
                    icon: Icons.block_rounded,
                    onTap: () {
                      Navigator.pop(sheetContext);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(SnackBar(content: Text('$name blocked.')));
                    },
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _goal(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: Spacing.md),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: GoogleFonts.dmSans(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
