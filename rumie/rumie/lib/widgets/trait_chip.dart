import 'package:flutter/material.dart';

import '../models/trait.dart';

class TraitChip extends StatelessWidget {
  final Trait trait;
  const TraitChip({super.key, required this.trait});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: trait.color.withAlpha(22),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: trait.color.withAlpha(90)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: trait.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            trait.title,
            style: TextStyle(
              color: trait.color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
