import 'package:flutter/material.dart';

import '../models/roommate.dart';
import '../widgets/nav_item.dart';
import 'listings_screen.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';
import 'swipe_screen.dart';

/// Three-tab shell matching the whiteboard sketch:
///   [Listings] [Swiping] [Profile]
/// Swiping is the default tab. The list of matches lives here and is
/// reached via a heart icon in the swipe screen's header.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // start on Swiping
  final List<Roommate> _matches = [];

  void _addMatch(Roommate r) => setState(() => _matches.add(r));

  void _openMatches() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MatchesScreen(matches: _matches)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const ListingsScreen(),
      SwipeScreen(
        onMatch: _addMatch,
        matchCount: _matches.length,
        onOpenMatches: _openMatches,
      ),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                NavItem(
                  emoji: '🏠',
                  label: 'Listings',
                  active: _currentIndex == 0,
                  onTap: () => setState(() => _currentIndex = 0),
                ),
                NavItem(
                  emoji: '🎴',
                  label: 'Swiping',
                  active: _currentIndex == 1,
                  onTap: () => setState(() => _currentIndex = 1),
                ),
                NavItem(
                  emoji: '😊',
                  label: 'Profile',
                  active: _currentIndex == 2,
                  onTap: () => setState(() => _currentIndex = 2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
