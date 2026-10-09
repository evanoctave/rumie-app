import 'package:flutter/material.dart';

import '../services/value_score.dart';
import '../theme/app_colors.dart';
import '../theme/app_shapes.dart';
import '../theme/app_text.dart';
import 'rumie_icon.dart';
import 'ui/app_chip.dart';
import 'ui/photo.dart';
import 'ui/score_ring.dart';

class ListingCard extends StatelessWidget {
  final String title;
  final String type;
  final String location;
  final int rent;

  /// Null when the listing has no beds/baths info (not an API field).
  final String? bedsBaths;

  /// Null when unknown; `'Now'` renders the "Available Now" chip.
  final String? availableDate;

  /// First of `ListingOut.photo_urls`, shown as the card image when present.
  final String? photoUrl;

  final ValueScore? valueScore;
  final int animationIndex;

  const ListingCard({
    super.key,
    required this.title,
    required this.type,
    required this.location,
    required this.rent,
    this.bedsBaths,
    this.availableDate,
    this.photoUrl,
    this.valueScore,
    this.animationIndex = 0,
  });

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
    final score = valueScore;
    final photo = photoUrl;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: AppColors.surface,
        shape: AppShapes.shape(AppShapes.card - 4, side: BorderSide(color: AppColors.line)),
        shadows: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photo != null && photo.isNotEmpty)
            SizedBox(
              height: 160,
              width: double.infinity,
              child: RumiePhoto(path: photo, fallbackName: title),
            ),
          Padding(
            padding: const EdgeInsets.all(18),
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
                    if (score != null) ...[
                      const SizedBox(width: 12),
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
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    AppChip(label: type, style: AppChipStyle.accent, dense: true),
                    if (bedsBaths != null) AppChip(label: bedsBaths!, dense: true),
                    if (availableDate == 'Now')
                      AppChip(
                        label: 'Available Now',
                        dense: true,
                        leading: Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(color: AppColors.positive, shape: BoxShape.circle),
                        ),
                      )
                    else if (availableDate != null)
                      AppChip(label: 'Move-in $availableDate', dense: true),
                  ],
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
          ),
        ],
      ),
    );
  }
}
