import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

enum RumieButtonVariant { primary, secondary, ghost, danger }

/// Standard Rumie button: gradient primary, outlined secondary, quiet ghost.
/// Press-scale + haptic baked in.
class RumieButton extends StatefulWidget {
  final String label;
  final VoidCallback? onTap;
  final RumieButtonVariant variant;
  final IconData? icon;
  final bool expanded;
  final bool loading;

  const RumieButton({
    super.key,
    required this.label,
    required this.onTap,
    this.variant = RumieButtonVariant.primary,
    this.icon,
    this.expanded = true,
    this.loading = false,
  });

  @override
  State<RumieButton> createState() => _RumieButtonState();
}

class _RumieButtonState extends State<RumieButton> {
  bool _pressed = false;

  bool get _enabled => widget.onTap != null && !widget.loading;

  @override
  Widget build(BuildContext context) {
    final isPrimary = widget.variant == RumieButtonVariant.primary;
    final isDanger = widget.variant == RumieButtonVariant.danger;
    final isGhost = widget.variant == RumieButtonVariant.ghost;

    final fg = switch (widget.variant) {
      RumieButtonVariant.primary => Colors.white,
      RumieButtonVariant.secondary => AppColors.primary,
      RumieButtonVariant.ghost => AppColors.textSecondary,
      RumieButtonVariant.danger => AppColors.red,
    };

    final child = AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: Motion.fast,
      curve: Motion.spring,
      child: Container(
        width: widget.expanded ? double.infinity : null,
        padding: EdgeInsets.symmetric(
          vertical: 16,
          horizontal: widget.expanded ? 16 : 24,
        ),
        decoration: BoxDecoration(
          gradient: isPrimary && _enabled ? AppColors.primaryGradient : null,
          color:
              isPrimary
                  ? (_enabled ? null : AppColors.gray)
                  : isGhost
                  ? Colors.transparent
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(Radii.lg),
          border:
              isPrimary || isGhost
                  ? null
                  : Border.all(
                    color:
                        isDanger
                            ? AppColors.red.withAlpha(90)
                            : AppColors.borderBright,
                    width: 1.5,
                  ),
          boxShadow: isPrimary && _enabled ? AppColors.buttonShadow : null,
        ),
        child: Row(
          mainAxisSize: widget.expanded ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.loading) ...[
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(fg),
                ),
              ),
              const SizedBox(width: Spacing.sm),
            ] else if (widget.icon != null) ...[
              Icon(widget.icon, color: fg, size: 18),
              const SizedBox(width: Spacing.sm),
            ],
            Text(
              widget.label,
              style: GoogleFonts.dmSans(
                color: fg,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );

    return GestureDetector(
      onTapDown:
          _enabled
              ? (_) {
                HapticFeedback.lightImpact();
                setState(() => _pressed = true);
              }
              : null,
      onTapUp:
          _enabled
              ? (_) {
                setState(() => _pressed = false);
                widget.onTap!();
              }
              : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: child,
    );
  }
}
