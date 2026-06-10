import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Bookmark/heart toggle with a springy pop microinteraction.
class SaveButton extends StatefulWidget {
  final bool saved;
  final VoidCallback onToggle;
  final double size;

  /// true → heart (roommates), false → bookmark (listings).
  final bool heart;

  const SaveButton({
    super.key,
    required this.saved,
    required this.onToggle,
    this.size = 38,
    this.heart = false,
  });

  @override
  State<SaveButton> createState() => _SaveButtonState();
}

class _SaveButtonState extends State<SaveButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pop = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 350),
  );

  @override
  void dispose() {
    _pop.dispose();
    super.dispose();
  }

  void _tap() {
    HapticFeedback.mediumImpact();
    if (!widget.saved) _pop.forward(from: 0);
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.heart ? AppColors.pink : AppColors.primary;
    final iconOn =
        widget.heart ? Icons.favorite_rounded : Icons.bookmark_rounded;
    final iconOff =
        widget.heart
            ? Icons.favorite_border_rounded
            : Icons.bookmark_border_rounded;

    return GestureDetector(
      onTap: _tap,
      child: Container(
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          color:
              widget.saved
                  ? color.withAlpha(AppColors.isDark ? 50 : 28)
                  : AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.saved ? color.withAlpha(120) : AppColors.border,
            width: 1.5,
          ),
        ),
        child: ScaleTransition(
          scale: TweenSequence<double>([
            TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.45), weight: 40),
            TweenSequenceItem(
              tween: Tween(
                begin: 1.45,
                end: 1.0,
              ).chain(CurveTween(curve: Motion.spring)),
              weight: 60,
            ),
          ]).animate(_pop),
          child: Icon(
            widget.saved ? iconOn : iconOff,
            color: widget.saved ? color : AppColors.textSecondary,
            size: widget.size * 0.52,
          ),
        ),
      ),
    );
  }
}
