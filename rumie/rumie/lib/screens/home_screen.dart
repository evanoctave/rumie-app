import 'package:flutter/material.dart';

import '../models/roommate.dart';
import '../theme/app_colors.dart';
import '../widgets/nav_item.dart';
import 'listings_screen.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';
import 'swipe_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final List<Roommate> _matches = [];

  void _addMatch(Roommate roommate) {
    final exists = _matches.any((m) => m.name == roommate.name);
    if (!exists) {
      setState(() => _matches.add(roommate));
    }
  }

  void _openMatches() {
    setState(() => _selectedIndex = 1);
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      SwipeScreen(
        onMatch: _addMatch,
        matchCount: _matches.length,
        onOpenMatches: _openMatches,
      ),
      MatchesScreen(matches: _matches),
      const ListingsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopNavBar(),
            Expanded(child: pages[_selectedIndex]),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 14, 18, 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(0, 10),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavItem(
            icon: Icons.favorite,
            label: 'Discover',
            selected: _selectedIndex == 0,
            color: AppColors.pink,
            onTap: () => setState(() => _selectedIndex = 0),
          ),
          NavItem(
            icon: Icons.chat_bubble_outline,
            label: 'Matches',
            selected: _selectedIndex == 1,
            color: AppColors.blue,
            onTap: () => setState(() => _selectedIndex = 1),
          ),
          NavItem(
            icon: Icons.home_work_outlined,
            label: 'Listings',
            selected: _selectedIndex == 2,
            color: AppColors.green,
            onTap: () => setState(() => _selectedIndex = 2),
          ),
          NavItem(
            icon: Icons.person_outline,
            label: 'Profile',
            selected: _selectedIndex == 3,
            color: AppColors.purple,
            onTap: () => setState(() => _selectedIndex = 3),
          ),
        ],
      ),
    );
  }
}
