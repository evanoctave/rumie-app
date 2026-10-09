import 'package:flutter/material.dart';

import '../../domain/entities/entities.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_shapes.dart';
import '../../theme/app_text.dart';
import '../avatar_style.dart';
import 'app_button.dart';

/// Mutual-match celebration. Shown only when the server reports a match.
Future<void> showMatchDialog(
  BuildContext context, {
  required RoommateCandidate candidate,
  required VoidCallback onChat,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: AppColors.photoInk.withValues(alpha: 0.72),
    transitionDuration: AppMotion.of(context, AppMotion.slow),
    pageBuilder: (context, _, _) => _MatchDialog(candidate: candidate, onChat: onChat),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: AppMotion.enter, reverseCurve: AppMotion.exit);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(curved), child: child),
      );
    },
  );
}

class _MatchDialog extends StatelessWidget {
  final RoommateCandidate candidate;
  final VoidCallback onChat;
  const _MatchDialog({required this.candidate, required this.onChat});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Material(
            type: MaterialType.transparency,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.6, end: 1),
                  duration: AppMotion.of(context, AppMotion.celebrate),
                  curve: AppMotion.enter,
                  builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
                  child: Container(
                    width: 132,
                    height: 132,
                    clipBehavior: Clip.antiAlias,
                    decoration: ShapeDecoration(
                      shape: AppShapes.shape(40),
                      shadows: AppColors.accentGlow(0.45),
                    ),
                    child: CandidateArt(candidate: candidate),
                  ),
                ),
                const SizedBox(height: 28),
                Text("It's a match", textAlign: TextAlign.center, style: AppText.screenTitle.copyWith(color: AppColors.photoText)),
                const SizedBox(height: 8),
                Text(
                  'You and ${candidate.matchLabel} liked each other.',
                  textAlign: TextAlign.center,
                  style: AppText.bodyLarge.copyWith(color: AppColors.photoText.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 28),
                AppButton(
                  label: 'Say hi',
                  style: AppButtonStyle.onPhoto,
                  onTap: onChat,
                ),
                const SizedBox(height: 6),
                AppButton(
                  label: 'Keep looking',
                  style: AppButtonStyle.ghostOnPhoto,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
