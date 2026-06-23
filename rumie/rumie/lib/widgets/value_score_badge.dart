import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/value_score.dart';
import '../theme/app_colors.dart';

class ValueScoreBadge extends StatelessWidget {
  final ValueScore score;
  const ValueScoreBadge({super.key, required this.score});

  Color get _fg => score.isHigh
      ? AppColors.scoreHigh
      : score.isMid
          ? AppColors.scoreMid
          : AppColors.scoreLow;

  Color get _bg => score.isHigh
      ? AppColors.scoreHighBg
      : score.isMid
          ? AppColors.scoreMidBg
          : AppColors.scoreLowBg;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: _fg, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${score.overall}',
                style: GoogleFonts.syne(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _fg,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VALUE SCORE',
                    style: GoogleFonts.inter(
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      color: _fg,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    score.tier.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      color: _fg,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        _MiniBar(label: 'VS MEDIAN', value: score.priceScore / 100, color: _fg),
        const SizedBox(height: 4),
        _MiniBar(label: '\$/SQFT',   value: score.sqftScore   / 100, color: _fg),
        const SizedBox(height: 4),
        _MiniBar(label: 'TRANSIT',   value: score.transitScore / 100, color: _fg),
      ],
    );
  }
}

class _MiniBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _MiniBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 7,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 0.8,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: value.clamp(0.0, 1.0),
              backgroundColor: AppColors.borderSoft,
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 3,
            ),
          ),
        ),
      ],
    );
  }
}
