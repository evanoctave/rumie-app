import 'package:flutter/material.dart';
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: Row(
        children: [
          Text(
            'Matches',
            style: GoogleFonts.syne(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: -0.8,
            ),
          ),
          const Spacer(),
          if (matches.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.text,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${matches.length} NEW',
                style: GoogleFonts.inter(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.background,
                  letterSpacing: 1.5,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
      itemCount: matches.length,
      itemBuilder: (context, i) => MatchTile(roommate: matches[i]),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'NO\nMATCHES\nYET',
            textAlign: TextAlign.center,
            style: GoogleFonts.syne(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: -1.5,
              height: 0.95,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Connect with someone in Discover\nand wait for them to respond.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
