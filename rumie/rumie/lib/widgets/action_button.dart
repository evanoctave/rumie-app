import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Circular swipe action button. Used for the ✕ (pass) and ✓ (like)
/// buttons under the swipe deck.
class ActionButton extends StatelessWidget {
  final String label;
  final double size;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const ActionButton({
    super.key,
    required this.label,
    required this.size,
    required this.onTap,
    this.background = Colors.white,
    this.foreground = AppColors.darkText,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: background,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: size * 0.42,
              color: foreground,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}
