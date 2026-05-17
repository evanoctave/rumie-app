import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final List<Roommate> _matches = [];
  late AnimationController _pageController;

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
  void initState() {
    super.initState();
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == _selectedIndex) return;
    _pageController.reverse().then((_) {
      setState(() => _selectedIndex = index);
      _pageController.forward();
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
      body: SafeArea(
        child: Column(
          children: [
            _buildTopNavBar(),
            Expanded(
              child: AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _pageController.value,
                    child: Transform.translate(
                      offset: Offset(0, 8 * (1 - _pageController.value)),
                      child: child,
                    ),
                  );
                },
                child: pages[_selectedIndex],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(80),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: AppColors.purple.withAlpha(20),
            blurRadius: 40,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          NavItem(
            icon: Icons.favorite_rounded,
            label: 'Discover',
            selected: _selectedIndex == 0,
            color: AppColors.pink,
            onTap: () => _onTabTap(0),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              NavItem(
                icon: Icons.chat_bubble_rounded,
                label: 'Matches',
                selected: _selectedIndex == 1,
                color: AppColors.blue,
                onTap: () => _onTabTap(1),
              ),
              if (_matches.isNotEmpty)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      gradient: AppColors.pinkPurpleGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${_matches.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scaleXY(begin: 0.9, end: 1.1, duration: 800.ms),
                ),
            ],
          ),
          NavItem(
            icon: Icons.home_work_rounded,
            label: 'Listings',
            selected: _selectedIndex == 2,
            color: AppColors.green,
            onTap: () => _onTabTap(2),
          ),
          NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            selected: _selectedIndex == 3,
            color: AppColors.purple,
            onTap: () => _onTabTap(3),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: -0.1, curve: Curves.easeOut);
  }
}
