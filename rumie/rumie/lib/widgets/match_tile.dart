import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../domain/entities/match.dart';
import '../theme/app_colors.dart';
import '../theme/tokens.dart';
import 'match_score_pill.dart';
import 'rumie_avatar.dart';

/// Row in the Matches list: avatar, name/school, last message, unread badge.
class MatchTile extends StatelessWidget {
  final RoommateMatch match;
  final VoidCallback onTap;
  final int animationIndex;

  const MatchTile({
    super.key,
    required this.match,
    required this.onTap,
    this.animationIndex = 0,
  });

  String get _timeLabel {
    final diff = DateTime.now().difference(match.matchedAt);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }

  @override
  Widget build(BuildContext context) {
    final p = match.profile;
    final hasUnread = match.unreadCount > 0;

    return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(Radii.card),
              border: Border.all(
                color: hasUnread ? AppColors.borderBright : AppColors.border,
                width: 1.5,
              ),
              boxShadow: AppColors.cardShadow,
            ),
            child: Row(
              children: [
                RumieAvatar(
                  asset: p.avatarAsset,
                  name: p.name,
                  id: p.id,
                  size: 54,
                ),
                const SizedBox(width: Spacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              p.name,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                          Text(
                            _timeLabel,
                            style: GoogleFonts.dmSans(
                              fontSize: 11.5,
                              color: AppColors.gray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.school,
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              match.lastMessagePreview,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.dmSans(
                                fontSize: 13,
                                color:
                                    hasUnread
                                        ? AppColors.text
                                        : AppColors.textSecondary,
                                fontWeight:
                                    hasUnread
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                              ),
                            ),
                          ),
                          const SizedBox(width: Spacing.sm),
                          MatchScorePill(score: match.compatibilityScore),
                          if (hasUnread) ...[
                            const SizedBox(width: Spacing.sm),
                            Container(
                              width: 20,
                              height: 20,
                              decoration: const BoxDecoration(
                                gradient: AppColors.pinkGradient,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '${match.unreadCount}',
                                  style: GoogleFonts.dmSans(
                                    color: Colors.white,
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
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
        .animate(delay: (50 * animationIndex).ms)
        .fadeIn(duration: Motion.entrance)
        .slideY(begin: 0.06, end: 0, curve: Motion.ease);
  }
}
