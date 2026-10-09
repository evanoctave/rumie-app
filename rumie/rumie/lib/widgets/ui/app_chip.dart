import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_text.dart';
import 'pressable.dart';

enum AppChipStyle { neutral, accent, onPhoto, outline }

/// Pill label. Pass [onTap] + [selected] for a toggle chip; the fill and
/// ink cross-fade instead of snapping.
class AppChip extends StatelessWidget {
  final String label;
  final AppChipStyle style;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;
  final Widget? trailing;
  final bool dense;

  const AppChip({
    super.key,
    required this.label,
    this.style = AppChipStyle.neutral,
    this.selected = false,
    this.onTap,
    this.leading,
    this.trailing,
    this.dense = false,
  });

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Color? line) = selected
        ? (AppColors.text, AppColors.background, null)
        : switch (style) {
            AppChipStyle.neutral => (AppColors.surfaceRaised, AppColors.text, null),
            AppChipStyle.accent => (AppColors.accentSoft, AppColors.accentDeep, null),
            AppChipStyle.onPhoto => (AppColors.photoText.withValues(alpha: 0.18), AppColors.photoText, AppColors.photoText.withValues(alpha: 0.28)),
            AppChipStyle.outline => (Colors.transparent, AppColors.text, AppColors.lineStrong),
          };

    final chip = AnimatedContainer(
      duration: AppMotion.of(context, AppMotion.base),
      curve: AppMotion.standard,
      padding: EdgeInsets.symmetric(horizontal: dense ? 10 : 14, vertical: dense ? 6 : 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: line ?? bg, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 6)],
          AnimatedDefaultTextStyle(
            duration: AppMotion.of(context, AppMotion.base),
            style: AppText.chip.copyWith(color: fg, fontSize: dense ? 12 : 13),
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          if (trailing != null) ...[const SizedBox(width: 6), trailing!],
        ],
      ),
    );

    if (onTap == null) return chip;
    return Pressable(onTap: onTap, pressedScale: 0.94, selected: selected, semanticLabel: label, child: chip);
  }
}
