import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'avatar_style.dart';

class TraitChip extends StatelessWidget {
  final String label;

  /// Defaults to a stable color derived from [label].
  final Color? color;

  const TraitChip({super.key, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AvatarStyle.traitColor(label);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: c.withAlpha(16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withAlpha(60), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: c, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.dmSans(
              color: c,
              fontWeight: FontWeight.w700,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}
