import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

import '../data/sample_data.dart';
import '../models/roommate.dart';
import '../theme/app_colors.dart';
import '../widgets/discover_card.dart';

class SwipeScreen extends StatefulWidget {
  final void Function(Roommate) onMatch;
  final int matchCount;
  final VoidCallback onOpenMatches;

  const SwipeScreen({
    super.key,
    required this.onMatch,
    required this.matchCount,
    required this.onOpenMatches,
  });

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  final Set<int> _passed = {};
  final Set<int> _connected = {};

  List<MapEntry<int, Roommate>> get _visible => sampleRoommates
      .asMap()
      .entries
      .where((e) => !_passed.contains(e.key) && !_connected.contains(e.key))
      .toList();

  void _pass(int originalIndex) => setState(() => _passed.add(originalIndex));

  void _connect(int originalIndex) {
    setState(() => _connected.add(originalIndex));
    widget.onMatch(sampleRoommates[originalIndex]);
    _showConnectedSnack(sampleRoommates[originalIndex]);
  }

  void _showConnectedSnack(Roommate r) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Connected with ${r.name}!',
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visible;

    return ColoredBox(
      color: AppColors.background,
      child: Column(
        children: [
          _buildHeader(visible.length),
          Expanded(
            child: visible.isEmpty
                ? _buildEmpty()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 100),
                    itemCount: visible.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final entry = visible[i];
                      return DiscoverCard(
                        roommate: entry.value,
                        index: i,
                        onPass: () => _pass(entry.key),
                        onConnect: () => _connect(entry.key),
                        onTap: () => _openProfile(entry.value),
                      )
                          .animate()
                          .fadeIn(delay: (60 * i).ms, duration: 280.ms)
                          .slideY(
                            begin: 0.05,
                            delay: (60 * i).ms,
                            duration: 280.ms,
                            curve: Curves.easeOutCubic,
                          );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(int count) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 14),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: Row(
        children: [
          Text(
            'Discover',
            style: GoogleFonts.syne(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: -0.8,
            ),
          ),
          const Spacer(),
          Text(
            '$count near you',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "YOU'VE\nSEEN ALL",
            textAlign: TextAlign.center,
            style: GoogleFonts.syne(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
              letterSpacing: -1.5,
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back soon for new roommates.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _openProfile(Roommate r) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${r.name} — full profile coming in Task 13')),
    );
  }
}
