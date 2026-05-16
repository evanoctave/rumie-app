// lib/screens/home_screen.dart

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
      setState(() {
        _matches.add(roommate);
      });
    }
  }

  void _openMatches() {
    setState(() {
      _selectedIndex = 1;
    });
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
      body: Stack(
        children: [
          Positioned(
            top: 120,
            left: -40,
            child: _blob(
              AppColors.softPink,
              120,
            ),
          ),
          Positioned(
            bottom: 160,
            right: -50,
            child: _blob(
              AppColors.softBlue,
              140,
            ),
          ),
          pages[_selectedIndex],
        ],
      ),
      bottomNavigationBar: _buildNavBar(),
    );
  }

  Widget _buildNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 20),
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppColors.darkText,
          width: 3,
        ),
        boxShadow: const [
          BoxShadow(
            color: AppColors.darkText,
            offset: Offset(4, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavItem(
            emoji: '💘',
            label: 'Discover',
            active: _selectedIndex == 0,
            onTap: () {
              setState(() => _selectedIndex = 0);
            },
          ),
          NavItem(
            emoji: '💬',
            label: 'Matches',
            active: _selectedIndex == 1,
            badge: _matches.length,
            onTap: () {
              setState(() => _selectedIndex = 1);
            },
          ),
          NavItem(
            emoji: '🏠',
            label: 'Listings',
            active: _selectedIndex == 2,
            onTap: () {
              setState(() => _selectedIndex = 2);
            },
          ),
          NavItem(
            emoji: '👤',
            label: 'Profile',
            active: _selectedIndex == 3,
            onTap: () {
              setState(() => _selectedIndex = 3);
            },
          ),
        ],
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
