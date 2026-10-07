import 'package:flutter/material.dart';

import '../di/locator.dart';
import '../domain/entities/entities.dart';
import '../domain/errors/error_messages.dart';
import '../domain/repositories/conversations_repository.dart';
import '../domain/repositories/listings_repository.dart';
import '../theme/app_colors.dart';
import '../theme/app_motion.dart';
import '../theme/app_text.dart';
import '../widgets/match_tile.dart';
import '../widgets/state_views.dart';
import '../widgets/ui/reveal.dart';
import '../widgets/ui/screen_header.dart';
import 'home_screen.dart';

class MatchesScreen extends StatefulWidget {
  /// Reports the loaded match count so the nav badge stays in sync.
  final void Function(int count)? onLoaded;

  const MatchesScreen({super.key, this.onLoaded});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  List<MatchSummary> matches = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool showSpinner = true}) async {
    // Already in the loading state on first run (called from initState).
    if (showSpinner && !_loading) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final convs = await locator<ConversationsRepository>().listConversations();
      final summaries = await Future.wait(convs.map(_summarize));
      if (!mounted) return;
      setState(() {
        matches = summaries;
        _loading = false;
        _error = null;
      });
      widget.onLoaded?.call(summaries.length);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = userMessage(e, fallback: "Couldn't load your matches.");
        _loading = false;
      });
    }
  }

  /// Listing inquiries are titled by their listing; a failed lookup just
  /// falls back to a generic title.
  Future<MatchSummary> _summarize(ConversationOut c) async {
    ListingOut? listing;
    final id = c.listingId;
    if (c.type == ConversationType.landlordInquiry && id != null) {
      try {
        listing = await locator<ListingsRepository>().get(id);
      } catch (_) {}
    }
    return MatchSummary.fromConversation(c, listing: listing);
  }

  String get _subtitle {
    if (_loading) return 'Checking for new connections';
    if (_error != null) return 'Something went wrong';
    if (matches.isEmpty) return 'People you match with land here';
    return '${matches.length} ${matches.length == 1 ? 'connection' : 'connections'}';
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = kNavClearance + MediaQuery.paddingOf(context).bottom;
    final Widget body;
    if (_loading) {
      body = const LoadingView(key: ValueKey('loading'));
    } else if (_error != null) {
      body = ErrorView(key: const ValueKey('error'), message: _error!, onRetry: _load);
    } else if (matches.isEmpty) {
      body = const _Empty(key: ValueKey('empty'));
    } else {
      body = RefreshIndicator(
        key: const ValueKey('list'),
        color: AppColors.accent,
        onRefresh: () => _load(showSpinner: false),
        child: ListView.separated(
          padding: EdgeInsets.fromLTRB(16, 4, 16, bottomPad),
          physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
          itemCount: matches.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, i) => Reveal(
            key: ValueKey(matches[i].id),
            index: i,
            child: MatchTile(match: matches[i]),
          ),
        ),
      );
    }

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: ScreenHeader(title: 'Matches', subtitle: _subtitle),
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
                'Connect with someone in Discover.\nWhen they like you back, the chat opens here.',
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
