import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/sample_data.dart';
import '../models/roommate.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_text.dart';
import '../widgets/discover_card.dart';
import '../widgets/ui/app_button.dart';
import '../widgets/ui/photo.dart';
import '../widgets/ui/reveal.dart';
import '../widgets/ui/screen_header.dart';
import '../widgets/ui/toast.dart';
import 'home_screen.dart';
import 'profile_view_screen.dart';

/// Discover: a vertical feed of photo cards. Pass slides a card out to the
/// left and collapses the gap; Connect slides it right and raises a toast.
class SwipeScreen extends StatefulWidget {
  final void Function(Roommate) onMatch;
  final int matchCount;
  final VoidCallback onOpenMatches;
  final void Function(Roommate) onSayHi;

  const SwipeScreen({
    super.key,
    required this.onMatch,
    required this.matchCount,
    required this.onOpenMatches,
    required this.onSayHi,
  });

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  late List<Roommate> _items = List.of(sampleRoommates);
  int _generation = 0;

  Future<void> _openProfile(Roommate r) async {
    final liked = await Navigator.of(context).push<bool>(ProfileViewScreen.route(r));
    if (!mounted || liked == null) return;
    if (liked) {
      _connect(r);
    } else {
      _pass(r);
    }
  }

  void _pass(Roommate r) {
    HapticFeedback.lightImpact();
    _remove(r, liked: false);
  }

  void _connect(Roommate r) {
    HapticFeedback.mediumImpact();
    _remove(r, liked: true);
    widget.onMatch(r);
    showTopToast(
      context,
      leading: Avatar(path: r.avatarAsset, name: r.name, size: 44, tint: r.gradient),
      title: 'You connected with ${r.name}',
      subtitle: 'They are in your matches now.',
      actionLabel: 'Say hi',
      onAction: () => widget.onSayHi(r),
    );
  }

  void _remove(Roommate r, {required bool liked}) {
    final i = _items.indexOf(r);
    if (i < 0) return;
    setState(() => _items.removeAt(i));
    _listKey.currentState?.removeItem(
      i,
      (context, animation) => _LeavingCard(roommate: r, animation: animation, liked: liked),
      duration: AppMotion.of(context, const Duration(milliseconds: 420)),
    );
  }

  void _restart() {
    HapticFeedback.selectionClick();
    setState(() {
      _items = List.of(sampleRoommates);
      _listKey = GlobalKey<AnimatedListState>();
      _generation++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = kNavClearance + MediaQuery.paddingOf(context).bottom;
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: ScreenHeader(
            title: 'Discover',
            subtitle: _items.isEmpty
                ? 'No one new right now'
                : '${_items.length} ${_items.length == 1 ? 'person' : 'people'} near you',
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: AppMotion.of(context, AppMotion.slow),
            switchInCurve: AppMotion.enter,
            switchOutCurve: AppMotion.exit,
            child: _items.isEmpty
                ? _EmptyDiscover(key: const ValueKey('empty'), onRestart: _restart)
                : AnimatedList(
                    key: _listKey,
                    initialItemCount: _items.length,
                    padding: EdgeInsets.fromLTRB(16, 4, 16, bottomPad),
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, i, animation) {
                      final r = _items[i];
                      return Reveal(
                        key: ValueKey('reveal-$_generation-${r.name}'),
                        index: i,
                        offsetY: 28,
                        scaleFrom: 0.97,
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: DiscoverCard(
                            roommate: r,
                            onPass: () => _pass(r),
                            onConnect: () => _connect(r),
                            onTap: () => _openProfile(r),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

/// Snapshot of a removed card: slides sideways, fades, and collapses.
class _LeavingCard extends StatelessWidget {
  final Roommate roommate;
  final Animation<double> animation;
  final bool liked;

  const _LeavingCard({required this.roommate, required this.animation, required this.liked});

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
                roommate: roommate,
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
  final VoidCallback onRestart;
  const _EmptyDiscover({super.key, required this.onRestart});

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
              Text("You've met everyone", style: AppText.sectionTitle, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'New people show up here as they join.\nCheck back soon.',
                style: AppText.secondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Start over',
                style: AppButtonStyle.tonal,
                size: AppButtonSize.medium,
                expand: false,
                onTap: onRestart,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
