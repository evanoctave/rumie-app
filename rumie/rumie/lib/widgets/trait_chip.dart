import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/trait.dart';

class TraitChip extends StatelessWidget {
  final Trait trait;
  const TraitChip({super.key, required this.trait});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: trait.color.withAlpha(16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: trait.color.withAlpha(60), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: trait.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            trait.title,
            style: GoogleFonts.dmSans(
              color: trait.color,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
