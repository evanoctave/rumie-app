import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../domain/entities/roommate_group.dart';
import '../state/group_provider.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import '../widgets/empty_state.dart';
import '../widgets/rumie_avatar.dart';
import '../widgets/rumie_button.dart';
import '../widgets/rumie_card.dart';
import '../widgets/rumie_chip.dart';
import '../widgets/section_header.dart';
import '../widgets/skeleton_card.dart';

/// Roommate group: shared budget, members, preferred listing, group actions.
class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  @override
  void initState() {
    super.initState();
    final groups = context.read<GroupProvider>();
    if (groups.loading) groups.load();
  }

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<GroupProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'My Group',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.text,
          ),
        ),
      ),
      body:
          groups.loading
              ? ListView(
                padding: const EdgeInsets.all(Spacing.gutter),
                children: const [SkeletonCard(height: 200)],
              )
              : groups.group == null
              ? EmptyState(
                icon: Icons.groups_rounded,
                title: 'No group yet',
                message:
                    'Match with roommates you like, then start\na group to browse housing together.',
                ctaLabel: 'Find roommates',
                onCta: () => Navigator.pop(context),
              )
              : _buildGroup(context, groups.group!),
    );
  }

  Widget _buildGroup(BuildContext context, RoommateGroup group) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.gutter,
        Spacing.lg,
        Spacing.gutter,
        40,
      ),
      children: [
        RumieCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleGreenGradient,
                      borderRadius: BorderRadius.circular(Radii.md),
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
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
                          group.name,
                          style: GoogleFonts.dmSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                        Text(
                          '${group.members.length} members · ${group.budgetLabel}',
                          style: GoogleFonts.dmSans(
                            fontSize: 12.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),
              Wrap(
                spacing: Spacing.sm,
                runSpacing: Spacing.sm,
                children: [
                  for (final hood in group.preferredNeighborhoods)
                    RumieChip(label: hood, color: AppColors.blue),
                  if (group.preferredListingId != null)
                    const RumieChip(
                      label: 'Listing attached',
                      color: AppColors.green,
                      icon: Icons.home_rounded,
                    ),
                ],
              ),
            ],
          ),
        ).animate().fadeIn(duration: Motion.entrance),
        const SizedBox(height: Spacing.xxl),
        const SectionHeader(title: 'Members'),
        const SizedBox(height: Spacing.md),
        for (final (i, member) in group.members.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: Spacing.md),
            child: RumieCard(
                  child: Row(
                    children: [
                      RumieAvatar(
                        asset: member.avatarAsset,
                        name: member.name,
                        id: member.id,
                        size: 44,
                      ),
                      const SizedBox(width: Spacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.id == 'me'
                                  ? '${member.name} (you)'
                                  : member.name,
                              style: GoogleFonts.dmSans(
                                fontSize: 14.5,
                                fontWeight: FontWeight.w700,
                                color: AppColors.text,
                              ),
                            ),
                            Text(
                              '${member.school} · ${member.budgetLabel}',
                              style: GoogleFonts.dmSans(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (member.isVerified)
                        const Icon(
                          Icons.verified_rounded,
                          color: AppColors.green,
                          size: 18,
                        ),
                    ],
                  ),
                )
                .animate(delay: (60 * i).ms)
                .fadeIn(duration: Motion.entrance)
                .slideY(begin: 0.06, end: 0, curve: Motion.ease),
          ),
        const SizedBox(height: Spacing.md),
        const SectionHeader(title: 'Compatibility'),
        const SizedBox(height: Spacing.md),
        RumieCard(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.bolt_rounded, color: AppColors.yellow, size: 20),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Text(
                  group.compatibilitySummary,
                  style: GoogleFonts.dmSans(
                    fontSize: 13.5,
                    color: AppColors.text,
                    height: 1.55,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.xxxl),
        RumieButton(
          label: 'Invite a roommate',
          icon: Icons.person_add_rounded,
          variant: RumieButtonVariant.secondary,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invites ship with the live groups API'),
              ),
            );
          },
        ),
        const SizedBox(height: Spacing.md),
        RumieButton(
          label: 'Browse housing as a group',
          icon: Icons.home_work_rounded,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(height: Spacing.md),
        RumieButton(
          label: 'Open group chat',
          icon: Icons.chat_bubble_rounded,
          variant: RumieButtonVariant.ghost,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Group chat ships with the live API'),
              ),
            );
          },
        ),
      ],
    );
  }
}
