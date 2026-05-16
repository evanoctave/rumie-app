import 'package:flutter/material.dart';

import '../models/roommate.dart';
import '../theme/app_colors.dart';
import '../widgets/match_tile.dart';

class MatchesScreen extends StatelessWidget {
  final List<Roommate> matches;
  const MatchesScreen({super.key, required this.matches});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              children: [
                ShaderMask(
                  shaderCallback: (rect) =>
                      AppColors.brandGradient.createShader(rect),
                  child: const Text(
                    'Your Matches',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('💜', style: TextStyle(fontSize: 24)),
              ],
            ),
          ),
          Expanded(
            child: matches.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: matches.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) => MatchTile(roommate: matches[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('💌', style: TextStyle(fontSize: 80)),
          SizedBox(height: 20),
          Text(
            'No matches yet!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.darkText,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Start swiping to find your\nperfect roommate ✨',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: AppColors.gray, height: 1.5),
          ),
        ],
      ),
    );
  }
}
