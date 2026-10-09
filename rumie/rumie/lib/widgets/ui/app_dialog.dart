import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_shapes.dart';
import '../../theme/app_text.dart';
import 'app_button.dart';

/// Confirmation dialog. Scales in from 94% with a fade; returns true when
/// the primary action is chosen.
Future<bool> showAppDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
  bool danger = false,
}) async {
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    barrierColor: AppColors.photoInk.withValues(alpha: 0.5),
    transitionDuration: AppMotion.of(context, AppMotion.slow),
    pageBuilder: (context, _, _) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 20),
              decoration: ShapeDecoration(
                color: AppColors.surface,
                shape: AppShapes.shape(AppShapes.card),
                shadows: AppColors.floatingShadow,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.sectionTitle),
                  const SizedBox(height: 8),
                  Text(message, style: AppText.secondary),
                  const SizedBox(height: 22),
                  AppButton(
                    label: confirmLabel,
                    style: danger ? AppButtonStyle.danger : AppButtonStyle.primary,
                    size: AppButtonSize.medium,
                    onTap: () => Navigator.pop(context, true),
                  ),
                  const SizedBox(height: 6),
                  AppButton(
                    label: cancelLabel,
                    style: AppButtonStyle.ghost,
                    size: AppButtonSize.medium,
                    onTap: () => Navigator.pop(context, false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(parent: animation, curve: AppMotion.enter, reverseCurve: AppMotion.exit);
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(scale: Tween(begin: 0.94, end: 1.0).animate(curved), child: child),
      );
    },
  );
  return result ?? false;
}
