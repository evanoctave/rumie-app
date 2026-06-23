import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/trait.dart';
import '../theme/app_colors.dart';

class TraitChip extends StatelessWidget {
  final Trait trait;
  final bool accent;

  const TraitChip({super.key, required this.trait, this.accent = false});

  @override
  Widget build(BuildContext context) {
    final bg   = accent ? AppColors.accent : AppColors.chipBg;
    final fg   = accent ? const Color(0xFFF2F0EB) : AppColors.chipText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        trait.title.toUpperCase(),
        style: GoogleFonts.inter(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: 9,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
