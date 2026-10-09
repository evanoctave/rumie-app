import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../di/locator.dart';
import '../domain/entities/entities.dart';
import '../domain/repositories/conversations_repository.dart';
import '../state/auth_provider.dart';
import '../state/profile_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_shapes.dart';
import '../theme/app_text.dart';
import '../widgets/rumie_icon.dart';
import 'listings_screen.dart';
import 'matches_screen.dart';
import 'profile_screen.dart';
import 'swipe_screen.dart';

/// Four-tab shell. Tabs stay mounted so scroll position and deck state
/// survive switching; the active one fades and nudges into view.
class HomeScreen extends StatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late int _index = widget.initialIndex;

  /// Mutual matches = server conversations (drives the nav badge).
  int _matchCount = 0;

  @override
  void initState() {
    super.initState();
    _refreshMatchCount();
    // After the first frame: load() notifies listeners, which must not
    // happen while the tree is building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProfileProvider>().load(context.read<AuthProvider>().user);
    });
  }

  Future<void> _refreshMatchCount() async {
    try {
      final convs = await locator<ConversationsRepository>().listConversations();
      if (mounted) setState(() => _matchCount = convs.length);
    } catch (_) {
      // Badge is decorative; the Matches tab shows the real error state.
    }
  }

  void _onMatch(RoommateCandidate _) => _refreshMatchCount();

  void _select(int index) {
    if (index == _index) return;
    HapticFeedback.selectionClick();
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      SwipeScreen(
        onMatch: _onMatch,
        matchCount: _matchCount,
        onOpenMatches: () => _select(1),
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
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          for (var i = 0; i < pages.length; i++)
            _TabPage(active: i == _index, child: pages[i]),
        ],
      ),
      bottomNavigationBar: FloatingNav(
        index: _index,
        onSelect: _select,
        matchBadge: _matchCount,
      ),
    );
  }
}

class _TabPage extends StatelessWidget {
  final bool active;
  final Widget child;
  const _TabPage({required this.active, required this.child});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !active,
      child: ExcludeSemantics(
        excluding: !active,
        // Outgoing page drops out quickly; the incoming one eases in a
        // beat later, so two photo-heavy pages never sit at half opacity.
        child: AnimatedOpacity(
          opacity: active ? 1 : 0,
          duration: AppMotion.of(context, active ? AppMotion.slow : AppMotion.fast),
          curve: active ? const Interval(0.3, 1, curve: AppMotion.enter) : AppMotion.exit,
          child: AnimatedSlide(
            offset: active ? Offset.zero : const Offset(0, 0.012),
            duration: AppMotion.of(context, AppMotion.slow),
            curve: AppMotion.enter,
            child: TickerMode(enabled: active, child: child),
          ),
        ),
      ),
    );
  }
}

/// Height the nav occupies above the bottom safe area. Lists pad by this.
const double kNavClearance = 92;

class FloatingNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onSelect;
  final int matchBadge;

  const FloatingNav({
    super.key,
    required this.index,
    required this.onSelect,
    this.matchBadge = 0,
  });

  static const _items = [
    (asset: 'assets/icons/ic_discover.svg', label: 'Discover'),
    (asset: 'assets/icons/ic_matches.svg', label: 'Matches'),
    (asset: 'assets/icons/ic_listings.svg', label: 'Listings'),
    (asset: 'assets/icons/ic_profile.svg', label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Container(
          height: 68,
          padding: const EdgeInsets.all(5),
          decoration: ShapeDecoration(
            color: AppColors.surface,
            shape: AppShapes.shape(28, side: BorderSide(color: AppColors.line)),
            shadows: AppColors.floatingShadow,
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth / _items.length;
              return Stack(
                children: [
                  AnimatedPositioned(
                    duration: AppMotion.of(context, AppMotion.slow),
                    curve: AppMotion.emphasized,
                    left: index * w,
                    top: 0,
                    bottom: 0,
                    width: w,
                    child: DecoratedBox(
                      decoration: ShapeDecoration(
                        color: AppColors.accentSoft,
                        shape: AppShapes.shape(22),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (var i = 0; i < _items.length; i++)
                        Expanded(
                          child: _NavItem(
                            asset: _items[i].asset,
                            label: _items[i].label,
                            selected: i == index,
                            badge: i == 1 ? matchBadge : 0,
                            onTap: () => onSelect(i),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String asset;
  final String label;
  final bool selected;
  final int badge;
  final VoidCallback onTap;

  const _NavItem({
    required this.asset,
    required this.label,
    required this.selected,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$label tab',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: selected ? 1 : 0),
          duration: AppMotion.of(context, AppMotion.slow),
          curve: AppMotion.enter,
          builder: (context, t, _) {
            final color = Color.lerp(AppColors.textSecondary, AppColors.accentDeep, t)!;
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Transform.scale(
                      scale: 1 + 0.08 * t,
                      child: RumieIcon(asset: asset, size: 22, color: color),
                    ),
                    if (badge > 0)
                      Positioned(
                        top: -6,
                        right: -10,
                        child: AnimatedSwitcher(
                          duration: AppMotion.of(context, AppMotion.base),
                          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                          child: Container(
                            key: ValueKey(badge),
                            constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(color: AppColors.surface, width: 2),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '$badge',
                              style: AppText.micro.copyWith(color: AppColors.onAccent, fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: AppText.micro.copyWith(
                    color: color,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
