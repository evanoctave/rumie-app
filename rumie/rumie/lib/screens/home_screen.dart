import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../di/locator.dart';
import '../domain/entities/entities.dart';
import '../domain/repositories/conversations_repository.dart';
import '../state/auth_provider.dart';
import '../state/profile_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/rumie_icon.dart';
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
  late AnimationController _pageController;

  /// Mutual matches = server conversations (drives the nav badge).
  int _matchCount = 0;

  Future<void> _refreshMatchCount() async {
    try {
      final convs =
          await locator<ConversationsRepository>().listConversations();
      if (mounted) setState(() => _matchCount = convs.length);
    } catch (_) {
      // Badge is decorative; the Matches tab shows the real error state.
    }
  }

  void _addMatch(RoommateCandidate _) => _refreshMatchCount();

  void _openMatches() => setState(() => _selectedIndex = 1);

  @override
  void initState() {
    super.initState();
    _pageController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
      value: 1.0,
    );
    _refreshMatchCount();
    // After the first frame: load() notifies listeners, which must not
    // happen while the tree is building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileProvider>().load(context.read<AuthProvider>().user);
    });
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
    final pages = [
      SwipeScreen(
        onMatch: _addMatch,
        matchCount: _matchCount,
        onOpenMatches: _openMatches,
      ),
      MatchesScreen(
        onLoaded: (count) {
          if (count != _matchCount) setState(() => _matchCount = count);
        },
      ),
      const ListingsScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) => Opacity(
                opacity: _pageController.value,
                child: child,
              ),
              child: pages[_selectedIndex],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildFloatingNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingNav() {
    const items = [
      (asset: 'assets/icons/ic_discover.svg', label: 'Discover'),
      (asset: 'assets/icons/ic_matches.svg',  label: 'Matches'),
      (asset: 'assets/icons/ic_listings.svg', label: 'Listings'),
      (asset: 'assets/icons/ic_profile.svg',  label: 'Profile'),
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
              final showBadge = i == 1 && _matchCount > 0;

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
                        color: selected
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
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.gray,
                                ),
                              ),
                              const SizedBox(height: 4),
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 200),
                                style: TextStyle(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.gray,
                                  fontSize: 11,
                                  fontWeight: selected
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
                                      color: AppColors.primary.withAlpha(70),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '$_matchCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              )
                                  .animate(onPlay: (c) => c.repeat(reverse: true))
                                  .scaleXY(begin: 0.88, end: 1.12, duration: 900.ms, curve: Curves.easeInOut),
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
    ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack);
  }
}
