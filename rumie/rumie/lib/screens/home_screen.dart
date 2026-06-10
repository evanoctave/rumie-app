import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../state/matches_provider.dart';
import '../state/profile_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/rumie_icon.dart';
import 'housing_screen.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';
import 'saved_screen.dart';
import 'swipe_screen.dart';

/// App shell: Discover · Housing · Matches · Saved · Profile.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _pageController;

  static const int _matchesTab = 2;

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
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
    HapticFeedback.selectionClick();
    _pageController.reverse().then((_) {
      setState(() => _selectedIndex = index);
      _pageController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();

    final pages = [
      SwipeScreen(onOpenMatches: () => _onTabTap(_matchesTab)),
      const HousingScreen(),
      const MatchesScreen(),
      const SavedScreen(),
      ProfileScreen(
        profile: profileProvider.profile,
        onProfileUpdated: profileProvider.update,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: AnimatedBuilder(
              animation: _pageController,
              builder:
                  (context, child) =>
                      Opacity(opacity: _pageController.value, child: child),
              child: pages[_selectedIndex],
            ),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _buildFloatingNav()),
        ],
      ),
    );
  }

  Widget _buildFloatingNav() {
    final unread = context.watch<MatchesProvider>().unreadCount;

    const items = [
      (asset: 'assets/icons/ic_discover.svg', label: 'Discover'),
      (asset: 'assets/icons/ic_listings.svg', label: 'Housing'),
      (asset: 'assets/icons/ic_matches.svg', label: 'Matches'),
      (asset: 'assets/icons/ic_like.svg', label: 'Saved'),
      (asset: 'assets/icons/ic_profile.svg', label: 'Profile'),
    ];

    return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(28),
              boxShadow: AppColors.navShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              child: Row(
                children: List.generate(items.length, (i) {
                  final item = items[i];
                  final selected = _selectedIndex == i;
                  final showBadge = i == _matchesTab && unread > 0;

                  return Expanded(
                    child: Semantics(
                      label: '${item.label} tab',
                      selected: selected,
                      button: true,
                      excludeSemantics: true,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () => _onTabTap(i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color:
                                selected
                                    ? AppColors.softPurple
                                    : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AnimatedScale(
                                    scale: selected ? 1.12 : 1.0,
                                    duration: const Duration(milliseconds: 220),
                                    curve: Curves.easeOutBack,
                                    child: RumieIcon(
                                      asset: item.asset,
                                      size: 22,
                                      color:
                                          selected
                                              ? AppColors.primary
                                              : AppColors.gray,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  AnimatedDefaultTextStyle(
                                    duration: const Duration(milliseconds: 200),
                                    style: TextStyle(
                                      color:
                                          selected
                                              ? AppColors.primary
                                              : AppColors.gray,
                                      fontSize: 11,
                                      fontWeight:
                                          selected
                                              ? FontWeight.w700
                                              : FontWeight.w500,
                                    ),
                                    child: Text(item.label),
                                  ),
                                ],
                              ),
                              if (showBadge)
                                Positioned(
                                  top: 0,
                                  right: 10,
                                  child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          gradient: AppColors.primaryGradient,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withAlpha(70),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            '$unread',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      )
                                      .animate(
                                        onPlay: (c) => c.repeat(reverse: true),
                                      )
                                      .scaleXY(
                                        begin: 0.88,
                                        end: 1.12,
                                        duration: 900.ms,
                                        curve: Curves.easeInOut,
                                      ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack);
  }
}
