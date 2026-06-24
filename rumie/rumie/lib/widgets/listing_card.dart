import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/value_score.dart';
import '../theme/app_colors.dart';
import 'value_score_badge.dart';

class ListingCard extends StatelessWidget {
  final String title;
  final String type;
  final String location;
  final int rent;
  final String bedsBaths;
  final String availableDate;
  final int sqft;
  final ValueScore? valueScore;
  final int animationIndex;

  const ListingCard({
    super.key,
    required this.title,
    required this.type,
    required this.location,
    required this.rent,
    required this.bedsBaths,
    required this.availableDate,
    this.sqft = 0,
    this.valueScore,
    this.animationIndex = 0,
  });

  (String, String) get _bedBath {
    final parts = bedsBaths.split('/');
    return (parts.firstOrNull?.trim() ?? bedsBaths, parts.elementAtOrNull(1)?.trim() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final (beds, baths) = _bedBath;
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: AppColors.cardShadow,
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (valueScore != null) ...[
            ValueScoreBadge(score: valueScore!),
            const SizedBox(height: 12),
          ] else ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.borderSoft,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                'SCORE UNAVAILABLE',
                style: GoogleFonts.inter(
                  fontSize: 8,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '\$$rent',
                  style: GoogleFonts.syne(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.text,
                    letterSpacing: -1,
                  ),
                ),
                TextSpan(
                  text: '/mo',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            location,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: AppColors.borderSoft, thickness: 1, height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              _Spec(label: 'BED', value: beds),
              _Spec(label: 'BATH', value: baths),
              _Spec(label: 'MOVE-IN', value: availableDate),
              if (sqft > 0) _Spec(label: 'SQFT', value: '$sqft'),
            ],
          ),
        ],
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  final String label;
  final String value;
  const _Spec({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: GoogleFonts.syne(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 8,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
