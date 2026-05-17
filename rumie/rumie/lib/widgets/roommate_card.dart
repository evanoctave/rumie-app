import 'package:flutter/material.dart';

import '../models/roommate.dart';
import '../theme/app_colors.dart';
import 'trait_chip.dart';

class RoommateCard extends StatelessWidget {
  final Roommate roommate;
  final void Function(bool liked)? onTap;

  const RoommateCard({
    super.key,
    required this.roommate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(true),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 10, 4, 0),
        child: Stack(
          children: [
            Positioned(
              top: 90,
              left: -30,
              child: _blob(AppColors.yellow, 100),
            ),
            Positioned(
              bottom: 60,
              right: -35,
              child: _blob(AppColors.softBlue, 120),
            ),
            ListView(
              padding: const EdgeInsets.fromLTRB(6, 8, 6, 20),
              children: [
                Text(
                  '${roommate.name}, ${roommate.age}',
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: AppColors.darkText,
                      width: 4,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'PROFILE PHOTO PLACEHOLDER',
                      style: TextStyle(
                        color: AppColors.gray,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _mutualsBar(),
                const SizedBox(height: 18),
                _answerCard(
                  small: 'When do you feel most like yourself?',
                  large: roommate.bio,
                ),
                const SizedBox(height: 16),
                Text(
                  'Budget: \$${roommate.budget}/month',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: roommate.traits
                      .map((trait) => TraitChip(trait: trait))
                      .toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  roommate.location,
                  style: const TextStyle(
                    color: AppColors.gray,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _mutualsBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.group, color: AppColors.darkText),
          const SizedBox(width: 8),
          const Text(
            'Mutuals',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(width: 10),
          _pill('Sam Brown'),
          const SizedBox(width: 6),
          _pill('Jay Smith'),
        ],
      ),
    );
  }

  Widget _pill(String text) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.darkText, width: 3),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.darkText,
          ),
        ),
      ),
    );
  }

  Widget _answerCard({
    required String small,
    required String large,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.darkText, width: 4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            small,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            large,
            style: const TextStyle(
              fontFamily: 'serif',
              fontSize: 25,
              height: 1.05,
              fontWeight: FontWeight.w900,
              color: AppColors.darkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _blob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}
