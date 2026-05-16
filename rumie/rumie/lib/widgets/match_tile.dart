import 'package:flutter/material.dart';

import '../models/roommate.dart';
import '../theme/app_colors.dart';

class MatchTile extends StatelessWidget {
  final Roommate roommate;
  const MatchTile({super.key, required this.roommate});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: roommate.gradient,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(roommate.emoji, style: const TextStyle(fontSize: 32)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${roommate.name}, ${roommate.age}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '📍 ${roommate.location}  ·  \$${roommate.budget}/mo',
                  style: const TextStyle(fontSize: 13, color: AppColors.gray),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.softPurple,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text('💬', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
  }
}
