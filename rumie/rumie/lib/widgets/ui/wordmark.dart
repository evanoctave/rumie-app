import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

/// "rumie" with an accent full stop.
class Wordmark extends StatelessWidget {
  final double size;
  final Color? color;

  const Wordmark({super.key, this.size = 32, this.color});

  @override
  Widget build(BuildContext context) {
    final ink = color ?? AppColors.text;
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(text: 'rumie', style: AppText.hero.copyWith(fontSize: size, color: ink, letterSpacing: -size * 0.045)),
          TextSpan(text: '.', style: AppText.hero.copyWith(fontSize: size, color: AppColors.accent, letterSpacing: -size * 0.045)),
        ],
      ),
      semanticsLabel: 'Rumie',
    );
  }
}
