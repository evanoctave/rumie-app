// lib/screens/matches_screen.dart

import 'package:flutter/material.dart';

import '../models/roommate.dart';
import '../theme/app_colors.dart';
import '../widgets/match_tile.dart';

class MatchesScreen extends StatelessWidget {
  final List<Roommate> matches;

  const MatchesScreen({
    super.key,
    required this.matches,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 100,
              right: -30,
              child: _blob(
                AppColors.softPurple,
                110,
              ),
            ),
            Positioned(
              bottom: 120,
              left: -40,
              child: _blob(
                AppColors.softGreen,
                130,
              ),
            ),
            Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: matches.isEmpty ? _buildEmpty() : _buildMatches(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
      child: Row(
        children: [
          const Text(
            'Matches',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: AppColors.darkText,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: AppColors.blue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.darkText,
                width: 3,
              ),
            ),
            child: Text(
              '${matches.length}',
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.darkText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatches() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(22, 12, 22, 120),
      itemCount: matches.length,
      separatorBuilder: (_, __) => const SizedBox(height: 18),
      itemBuilder: (context, index) {
        return MatchTile(
          roommate: matches[index],
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                color: AppColors.softPink,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.darkText,
                  width: 4,
                ),
              ),
              child: const Center(
                child: Text(
                  'CHAT\nPLACEHOLDER',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.darkText,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'No matches yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'serif',
                fontSize: 34,
                fontWeight: FontWeight.w900,
                color: AppColors.darkText,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Start swiping to connect with potential roommates and begin chatting.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: AppColors.gray,
              ),
            ),
          ],
        ),
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
