import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/roommate.dart';
import '../theme/app_colors.dart';
import '../widgets/match_tile.dart';

class MatchesScreen extends StatelessWidget {
  final List<Roommate> matches;

  const MatchesScreen({super.key, required this.matches});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          _buildHeader(),
          Expanded(child: matches.isEmpty ? _buildEmpty() : _buildList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 18),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1.5),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Matches',
                style: GoogleFonts.dmSans(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  letterSpacing: -0.8,
                ),
              ),
              Text(
                'People who liked you back',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (matches.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Text(
                '${matches.length}',
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      itemCount: matches.length,
      separatorBuilder: (ctx, i) => const SizedBox(height: 12),
      itemBuilder: (context, index) => MatchTile(
        roommate: matches[index],
        animationIndex: index,
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.softPurple, Color(0xFFE0D9FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: AppColors.cardShadow,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/ic_matches.svg',
                  width: 40,
                  height: 40,
                  colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                ),
              ),
            ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
            const SizedBox(height: 24),
            Text(
              'No matches yet',
              style: GoogleFonts.dmSans(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
                letterSpacing: -0.4,
              ),
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 10),
            Text(
              'Swipe right on someone you like\nand wait for them to match back.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: AppColors.textSecondary,
                height: 1.55,
              ),
            ).animate().fadeIn(delay: 200.ms),
          ],
        ),
      ),
    );
  }
}
