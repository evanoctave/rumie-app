import 'package:flutter/material.dart';

import '../models/roommate.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_text.dart';
import '../widgets/match_tile.dart';
import '../widgets/ui/reveal.dart';
import '../widgets/ui/screen_header.dart';
import 'home_screen.dart';

class MatchesScreen extends StatelessWidget {
  final List<Roommate> matches;

  const MatchesScreen({super.key, required this.matches});

  @override
  Widget build(BuildContext context) {
    final bottomPad = kNavClearance + MediaQuery.paddingOf(context).bottom;
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: ScreenHeader(
            title: 'Matches',
            subtitle: matches.isEmpty
                ? 'People you connect with land here'
                : '${matches.length} ${matches.length == 1 ? 'connection' : 'connections'}',
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: AppMotion.of(context, AppMotion.slow),
            switchInCurve: AppMotion.enter,
            switchOutCurve: AppMotion.exit,
            child: matches.isEmpty
                ? const _Empty(key: ValueKey('empty'))
                : ListView.separated(
                    key: const ValueKey('list'),
                    padding: EdgeInsets.fromLTRB(16, 4, 16, bottomPad),
                    physics: const BouncingScrollPhysics(),
                    itemCount: matches.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, i) => Reveal(
                      key: ValueKey(matches[i].name),
                      index: i,
                      child: MatchTile(roommate: matches[i]),
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 80),
        child: Reveal(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(color: AppColors.accentSoft, shape: BoxShape.circle),
                child: const Center(child: Text('💬', style: TextStyle(fontSize: 38))),
              ),
              const SizedBox(height: 22),
              Text('No matches yet', style: AppText.sectionTitle),
              const SizedBox(height: 8),
              Text(
                'Connect with someone in Discover\nand start the conversation here.',
                style: AppText.secondary,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
