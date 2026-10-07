import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../di/locator.dart';
import '../domain/entities/entities.dart';
import '../domain/errors/error_messages.dart';
import '../domain/repositories/discovery_repository.dart';
import '../domain/repositories/swipe_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_text.dart';
import '../widgets/discover_card.dart';
import '../widgets/state_views.dart';
import '../widgets/ui/app_button.dart';
import '../widgets/ui/match_dialog.dart';
import '../widgets/ui/reveal.dart';
import '../widgets/ui/screen_header.dart';
import 'home_screen.dart';
import 'profile_view_screen.dart';

/// Discover: a vertical feed of candidate cards from the discovery API.
/// Pass slides a card out to the left and collapses the gap; Connect
/// slides it right. A match dialog appears only when the server reports
/// a mutual match.
class SwipeScreen extends StatefulWidget {
  final void Function(RoommateCandidate) onMatch;
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
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  List<RoommateCandidate> _deck = [];
  bool _loading = true;
  String? _error;
  int _generation = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Already in the loading state on first run (called from initState).
    if (!_loading) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final groups = await locator<DiscoveryRepository>().discoverGroups();
      if (!mounted) return;
      setState(() {
        _deck = groups.map(RoommateCandidate.fromGroup).toList();
        _listKey = GlobalKey<AnimatedListState>();
        _generation++;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userMessage(e, fallback: "Couldn't load profiles.");
        _loading = false;
      });
    }
  }

  Future<void> _openProfile(RoommateCandidate c) async {
    final liked = await Navigator.of(context).push<bool>(ProfileViewScreen.route(c));
    if (!mounted || liked == null) return;
    if (liked) {
      _connect(c);
    } else {
      _pass(c);
    }
  }

  void _pass(RoommateCandidate c) {
    HapticFeedback.lightImpact();
    _remove(c, liked: false);
    _recordSwipe(c, false);
  }

  void _connect(RoommateCandidate c) {
    HapticFeedback.mediumImpact();
    _remove(c, liked: true);
    _recordSwipe(c, true);
  }

  /// Sends the swipe; the match dialog only shows when the server reports a
  /// mutual match (V16: `merge` proposal on the group path).
  Future<void> _recordSwipe(RoommateCandidate c, bool liked) async {
    try {
      final out = await locator<SwipeRepository>().swipe(SwipeIn(
        targetId: c.id,
        targetType: c.targetType,
        direction: liked ? SwipeDirection.right : SwipeDirection.left,
      ));
      if (!mounted || !out.matched) return;
      HapticFeedback.heavyImpact();
      widget.onMatch(c);
      showMatchDialog(
        context,
        candidate: c,
        onChat: () {
          Navigator.pop(context);
          widget.onOpenMatches();
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(userMessage(e, fallback: "Couldn't save that swipe."))),
      );
    }
  }

  void _remove(RoommateCandidate c, {required bool liked}) {
    final i = _deck.indexOf(c);
    if (i < 0) return;
    setState(() => _deck.removeAt(i));
    _listKey.currentState?.removeItem(
      i,
      (context, animation) => _LeavingCard(candidate: c, animation: animation, liked: liked),
      duration: AppMotion.of(context, const Duration(milliseconds: 420)),
    );
  }

  String get _subtitle {
    if (_loading) return 'Finding people near you';
    if (_error != null) return 'Something went wrong';
    if (_deck.isEmpty) return 'No one new right now';
    return '${_deck.length} ${_deck.length == 1 ? 'person' : 'people'} near you';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = kNavClearance + MediaQuery.paddingOf(context).bottom;
    final Widget body;
    if (_loading) {
      body = const LoadingView(key: ValueKey('loading'));
    } else if (_error != null) {
      body = ErrorView(key: const ValueKey('error'), message: _error!, onRetry: _load);
    } else if (_deck.isEmpty) {
      body = _EmptyDiscover(key: const ValueKey('empty'), onReload: _load);
    } else {
      body = AnimatedList(
        key: _listKey,
        initialItemCount: _deck.length,
        padding: EdgeInsets.fromLTRB(16, 4, 16, bottomPad),
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, i, animation) {
          final c = _deck[i];
          return Reveal(
            key: ValueKey('reveal-$_generation-${c.id}'),
            index: i,
            offsetY: 28,
            scaleFrom: 0.97,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DiscoverCard(
                candidate: c,
                onPass: () => _pass(c),
                onConnect: () => _connect(c),
                onTap: () => _openProfile(c),
              ),
            ),
          );
        },
      );
    }

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: ScreenHeader(title: 'Discover', subtitle: _subtitle),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: AppMotion.of(context, AppMotion.slow),
            switchInCurve: AppMotion.enter,
            switchOutCurve: AppMotion.exit,
            child: body,
          ),
        ),
      ],
    );
  }
}

/// Snapshot of a removed card: slides sideways, fades, and collapses.
class _LeavingCard extends StatelessWidget {
  final RoommateCandidate candidate;
  final Animation<double> animation;
  final bool liked;

  const _LeavingCard({required this.candidate, required this.animation, required this.liked});

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: AppMotion.standard);
    return SizeTransition(
      sizeFactor: curved,
      axisAlignment: -1,
      child: FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween(begin: Offset(liked ? 1.15 : -1.15, 0), end: Offset.zero).animate(curved),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: IgnorePointer(
              child: DiscoverCard(
                candidate: candidate,
                heroEnabled: false,
                onPass: () {},
                onConnect: () {},
                onTap: () {},
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyDiscover extends StatelessWidget {
  final VoidCallback onReload;
  const _EmptyDiscover({super.key, required this.onReload});

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
                child: const Center(child: Text('👋', style: TextStyle(fontSize: 40))),
              ),
              const SizedBox(height: 22),
              Text("You've seen everyone", style: AppText.sectionTitle, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'New people show up here as they join.\nCheck back soon.',
                style: AppText.secondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Refresh',
                style: AppButtonStyle.tonal,
                size: AppButtonSize.medium,
                expand: false,
                onTap: onReload,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
