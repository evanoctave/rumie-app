import 'package:flutter/material.dart';

import '../services/value_score.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'ui/app_chip.dart';
import 'ui/score_ring.dart';

/// Value score for a listing: animated ring, tier label, three factor bars.
class ValueScoreBadge extends StatelessWidget {
  final ValueScore score;
  final bool showBars;
  const ValueScoreBadge({super.key, required this.score, this.showBars = true});

  Color get color => score.isHigh
      ? AppColors.scoreHigh
      : score.isMid
          ? AppColors.scoreMid
          : AppColors.scoreLow;

  Color get softColor => score.isHigh
      ? AppColors.scoreHighBg
      : score.isMid
          ? AppColors.scoreMidBg
          : AppColors.scoreLowBg;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ScoreRing(value: score.overall, color: color, size: 60),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Value score', style: AppText.label),
                const SizedBox(height: 6),
                _TierChip(label: score.tier, color: color, background: softColor),
              ],
            ),
          ],
        ),
        if (showBars) ...[
          const SizedBox(height: 14),
          MiniBar(label: 'vs median', value: score.priceScore / 100, color: color),
          const SizedBox(height: 6),
          MiniBar(label: '\$ per sqft', value: score.sqftScore / 100, color: color),
          const SizedBox(height: 6),
          MiniBar(label: 'Transit', value: score.transitScore / 100, color: color),
        ],
      ],
    );
  }
}

class _TierChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color background;
  const _TierChip({required this.label, required this.color, required this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(999)),
      child: Text(label, style: AppText.chip.copyWith(color: color, fontSize: 12)),
    );
  }
}

/// Keeps [AppChip] import used for callers that want a plain neutral tag.
typedef ScoreTag = AppChip;
