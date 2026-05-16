import 'package:flutter/material.dart';

import '../models/trait.dart';
import '../theme/app_colors.dart';

class TraitChip extends StatelessWidget {
  final Trait trait;
  const TraitChip({super.key, required this.trait});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.softPink,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(trait.emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            trait.label,
            style: const TextStyle(
              color: AppColors.darkText,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
