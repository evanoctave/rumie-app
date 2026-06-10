import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Simple static background — replaces the animated orb version.
/// Keeps the same widget interface so callers don't change.
class AnimatedBackground extends StatelessWidget {
  final Widget child;
  const AnimatedBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: AppColors.background, child: child);
  }
}
