import 'package:flutter/material.dart';

import '../models/roommate.dart';
import '../theme/app_colors.dart';
import 'trait_chip.dart';

/// Compact card used in the Listings tab. Shows enough info to scan
/// the list without opening detail (avatar, name+age, location, budget,
/// first two traits).
class ListingCard extends StatelessWidget {
  final Roommate roommate;
  final VoidCallback onTap;

  const ListingCard({
    super.key,
    required this.roommate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = roommate;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: r.gradient[0].withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: r.gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(r.emoji, style: const TextStyle(fontSize: 40)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '${r.name}, ${r.age}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkText,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.softPurple,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '\$${r.budget}',
                          style: const TextStyle(
                            color: AppColors.purple,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '📍 ${r.location}',
                    style: const TextStyle(fontSize: 13, color: AppColors.gray),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: r.traits
                        .take(2)
                        .map((t) => TraitChip(trait: t))
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
}
