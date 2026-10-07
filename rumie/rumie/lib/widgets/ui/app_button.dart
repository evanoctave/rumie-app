import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_motion.dart';
import '../../theme/app_shapes.dart';
import '../../theme/app_text.dart';
import '../rumie_icon.dart';
import 'pressable.dart';

enum AppButtonStyle { primary, tonal, secondary, ghost, danger, onPhoto, ghostOnPhoto }

enum AppButtonSize { large, medium, small }

/// The one button. Press scale, loading morphs into a spinner without
/// changing height, disabled dims.
class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final AppButtonStyle style;
  final AppButtonSize size;
  final bool loading;
  final bool expand;
  final String? iconAsset;
  final IconData? icon;
  final bool iconTrailing;

  const AppButton({
    super.key,
    required this.label,
    required this.onTap,
    this.style = AppButtonStyle.primary,
    this.size = AppButtonSize.large,
    this.loading = false,
    this.expand = true,
    this.iconAsset,
    this.icon,
    this.iconTrailing = false,
  });

  double get _height => switch (size) {
        AppButtonSize.large => 56,
        AppButtonSize.medium => 48,
        AppButtonSize.small => 40,
      };

  double get _radius => switch (size) {
        AppButtonSize.large => AppShapes.button,
        AppButtonSize.medium => 16,
        AppButtonSize.small => 14,
      };

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null && !loading;

    final (Color bg, Color fg, Color? line, List<BoxShadow> shadow) = switch (style) {
      AppButtonStyle.primary => (AppColors.accent, AppColors.onAccent, null, AppColors.accentGlow(0.28)),
      AppButtonStyle.tonal => (AppColors.accentSoft, AppColors.accentDeep, null, const []),
      AppButtonStyle.secondary => (AppColors.surface, AppColors.text, AppColors.lineStrong, const []),
      AppButtonStyle.ghost => (Colors.transparent, AppColors.textSecondary, null, const []),
      AppButtonStyle.danger => (AppColors.dangerSoft, AppColors.danger, null, const []),
      AppButtonStyle.onPhoto => (AppColors.photoText.withValues(alpha: 0.92), AppColors.photoInk, null, const []),
      AppButtonStyle.ghostOnPhoto => (Colors.transparent, AppColors.photoText.withValues(alpha: 0.85), null, const []),
    };

    final textStyle = (size == AppButtonSize.large ? AppText.button : AppText.buttonSmall)
        .copyWith(color: fg);

    final iconWidget = iconAsset != null
        ? RumieIcon(asset: iconAsset!, size: size == AppButtonSize.small ? 16 : 18, color: fg)
        : icon != null
            ? Icon(icon, size: size == AppButtonSize.small ? 18 : 20, color: fg)
            : null;

    final content = AnimatedSwitcher(
      duration: AppMotion.of(context, AppMotion.base),
      switchInCurve: AppMotion.enter,
      switchOutCurve: AppMotion.exit,
      transitionBuilder: (child, anim) => FadeTransition(
        opacity: anim,
        child: ScaleTransition(scale: Tween(begin: 0.85, end: 1.0).animate(anim), child: child),
      ),
      child: loading
          ? SizedBox(
              key: const ValueKey('spinner'),
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (iconWidget != null && !iconTrailing) ...[iconWidget, const SizedBox(width: 8)],
                Text(label, style: textStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
                if (iconWidget != null && iconTrailing) ...[const SizedBox(width: 8), iconWidget],
              ],
            ),
    );

    return Pressable(
      onTap: enabled ? onTap : null,
      pressedScale: 0.96,
      semanticLabel: label,
      child: AnimatedOpacity(
        opacity: onTap == null ? 0.45 : 1,
        duration: AppMotion.of(context, AppMotion.base),
        child: AnimatedContainer(
          duration: AppMotion.of(context, AppMotion.base),
          curve: AppMotion.standard,
          height: _height,
          width: expand ? double.infinity : null,
          padding: EdgeInsets.symmetric(horizontal: size == AppButtonSize.small ? 16 : 22),
          decoration: ShapeDecoration(
            color: bg,
            shape: AppShapes.shape(_radius, side: line != null ? BorderSide(color: line) : BorderSide.none),
            shadows: enabled ? shadow : const [],
          ),
          child: Center(child: content),
        ),
      ),
    );
  }
}
