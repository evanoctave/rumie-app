import 'package:flutter/material.dart';

import '../services/value_score.dart';
import '../theme/app_colors.dart';
import '../theme/app_shapes.dart';
import '../theme/app_text.dart';
import 'rumie_icon.dart';
import 'ui/app_chip.dart';
import 'ui/score_ring.dart';

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

  Color _tierColor(ValueScore s) => s.isHigh
      ? AppColors.scoreHigh
      : s.isMid
          ? AppColors.scoreMid
          : AppColors.scoreLow;

  Color _tierSoft(ValueScore s) => s.isHigh
      ? AppColors.scoreHighBg
      : s.isMid
          ? AppColors.scoreMidBg
          : AppColors.scoreLowBg;

  @override
  Widget build(BuildContext context) {
    final (beds, baths) = _bedBath;
    final score = valueScore;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: AppShapes.shape(AppShapes.card - 4, side: BorderSide(color: AppColors.line)),
        shadows: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: '\$$rent', style: AppText.cardName),
                          TextSpan(text: ' /mo', style: AppText.secondary),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(title, style: AppText.tileTitle, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        RumieIcon(asset: 'assets/icons/ic_location.svg', size: 13, color: AppColors.textTertiary),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(location, style: AppText.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              if (score != null)
                Column(
                  children: [
                    ScoreRing(value: score.overall, color: _tierColor(score), size: 58),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: _tierSoft(score), borderRadius: BorderRadius.circular(999)),
                      child: Text(score.tier, style: AppText.micro.copyWith(color: _tierColor(score))),
                    ),
                  ],
                )
              else
                const AppChip(label: 'Scoring…', dense: true),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: ShapeDecoration(
              color: AppColors.surfaceSunken,
              shape: AppShapes.shape(AppShapes.small + 2),
            ),
            child: Row(
              children: [
                _Spec(value: beds, label: 'Bed'),
                _Spec(value: baths, label: 'Bath'),
                _Spec(value: availableDate, label: 'Move-in'),
                if (sqft > 0) _Spec(value: '$sqft', label: 'Sq ft'),
              ],
            ),
          ),
          if (score != null) ...[
            const SizedBox(height: 14),
            MiniBar(label: 'vs median', value: score.priceScore / 100, color: _tierColor(score)),
            const SizedBox(height: 6),
            MiniBar(label: '\$ per sqft', value: score.sqftScore / 100, color: _tierColor(score)),
            const SizedBox(height: 6),
            MiniBar(label: 'Transit', value: score.transitScore / 100, color: _tierColor(score)),
          ],
        ],
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  final String value;
  final String label;
  const _Spec({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.caption.copyWith(fontSize: 12)),
          const SizedBox(height: 3),
          Text(
            value.replaceAll(RegExp(r'\s*(bed|bath)s?$', caseSensitive: false), ''),
            style: AppText.buttonSmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
