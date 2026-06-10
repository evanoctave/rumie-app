import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';
import '../theme/tokens.dart';

/// Pill chip. Tappable (filter) when [onTap] given, otherwise a static tag.
class RumieChip extends StatelessWidget {
  final String label;
  final Color? color;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  const RumieChip({
    super.key,
    required this.label,
    this.color,
    this.selected = false,
    this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;

    final chip = AnimatedContainer(
      duration: Motion.normal,
      curve: Motion.ease,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? c : c.withAlpha(AppColors.isDark ? 40 : 24),
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: selected ? c : c.withAlpha(70), width: 1.2),
        boxShadow:
            selected
                ? [
                  BoxShadow(
                    color: c.withAlpha(60),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
                : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: selected ? Colors.white : c),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: GoogleFonts.dmSans(
              color:
                  selected
                      ? Colors.white
                      : (AppColors.isDark ? c.withAlpha(255) : c),
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return chip;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap!();
      },
      child: chip,
    );
  }
}
