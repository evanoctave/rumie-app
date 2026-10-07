import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../rumie_icon.dart';
import 'pressable.dart';

enum CircleButtonStyle { surface, onPhoto, accent, danger }

/// Round icon button: back, close, pass, send.
class CircleButton extends StatelessWidget {
  final String? iconAsset;
  final IconData? icon;
  final VoidCallback? onTap;
  final double size;
  final CircleButtonStyle style;
  final String semanticLabel;

  const CircleButton({
    super.key,
    required this.onTap,
    required this.semanticLabel,
    this.iconAsset,
    this.icon,
    this.size = 44,
    this.style = CircleButtonStyle.surface,
  });

  @override
  Widget build(BuildContext context) {
    final (Color bg, Color fg, Color? line, List<BoxShadow> shadow) = switch (style) {
      CircleButtonStyle.surface => (AppColors.surface, AppColors.text, AppColors.line, AppColors.cardShadow),
      CircleButtonStyle.onPhoto => (AppColors.photoText.withValues(alpha: 0.9), AppColors.photoInk, null, const []),
      CircleButtonStyle.accent => (AppColors.accent, AppColors.onAccent, null, AppColors.accentGlow(0.3)),
      CircleButtonStyle.danger => (AppColors.surface, AppColors.danger, AppColors.line, AppColors.cardShadow),
    };
    final iconSize = size * 0.45;
    return Pressable(
      onTap: onTap,
      pressedScale: 0.9,
      semanticLabel: semanticLabel,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: line != null ? Border.all(color: line) : null,
          boxShadow: shadow,
        ),
        child: Center(
          child: iconAsset != null
              ? RumieIcon(asset: iconAsset!, size: iconSize, color: fg)
              : Icon(icon, size: iconSize, color: fg),
        ),
      ),
    );
  }
}
