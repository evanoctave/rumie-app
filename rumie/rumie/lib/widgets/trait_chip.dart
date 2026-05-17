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
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: trait.color,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            trait.title,
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
