import 'package:flutter/material.dart';

import '../models/trait.dart';

class TraitChip extends StatelessWidget {
  final Trait trait;
  const TraitChip({super.key, required this.trait});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: trait.color.withAlpha(18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: trait.color.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: trait.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: trait.color.withAlpha(120),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 7),
          Text(
            trait.title,
            style: TextStyle(
              color: trait.color,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
