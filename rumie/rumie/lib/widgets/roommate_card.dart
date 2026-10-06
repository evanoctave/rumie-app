import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../domain/entities/entities.dart';
import '../theme/app_colors.dart';
import 'avatar_style.dart';
import 'trait_chip.dart';

class RoommateCard extends StatelessWidget {
  final RoommateCandidate roommate;
  final void Function(bool liked)? onTap;

  const RoommateCard({super.key, required this.roommate, this.onTap});

  AvatarStyle get _style => AvatarStyle.forId(roommate.id);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(7),
        child: ListView(
          padding: EdgeInsets.zero,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _buildPhotoArea(),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          roommate.headline,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      if (roommate.budget != null) _budgetPill(),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/ic_location.svg',
                        width: 13,
                        height: 13,
                        colorFilter: ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        roommate.location,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      roommate.bio,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: roommate.tags
                        .asMap()
                        .entries
                        .map((e) => TraitChip(label: e.value)
                            .animate()
                            .fadeIn(delay: (40 * e.key).ms))
                        .toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoArea() {
    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _svgAvatar(),
          // gradient overlay at bottom for readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.cardBg.withAlpha(230),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _svgAvatar() {
    return Container(
      color: _style.gradient.first.withAlpha(60),
      child: Center(
        child: Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(18),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withAlpha(50), width: 2),
          ),
          child: ClipOval(
            child: SvgPicture.asset(_style.asset, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _budgetPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.softGreen,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.green.withAlpha(80)),
      ),
      child: Text(
        '\$${roommate.budget}/mo',
        style: const TextStyle(
          color: AppColors.green,
          fontWeight: FontWeight.w700,
          fontSize: 12,
        ),
      ),
    );
  }
}
