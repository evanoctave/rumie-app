import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roomie/di/locator.dart';
import 'package:roomie/domain/entities/entities.dart';
import 'package:roomie/domain/repositories/discovery_repository.dart';
import 'package:roomie/domain/repositories/swipe_repository.dart';
import 'package:roomie/screens/swipe_screen.dart';
import 'package:roomie/theme/app_theme.dart';
import 'package:roomie/widgets/discover_card.dart';
import 'package:roomie/widgets/ui/circle_button.dart';

class _FakeDiscovery implements DiscoveryRepository {
  @override
  Future<List<GroupOut>> discoverGroups({int limit = 20}) async => [
        for (final id in ['g1', 'g2', 'g3'])
          GroupOut(id: id, adminId: 'a-$id', members: ['a-$id'], preferences: const Preferences(budget: 1000), capacity: 2),
      ];

  @override
  Future<List<ListingOut>> discoverListings({int limit = 20}) async => [];
}

class _FakeSwipe implements SwipeRepository {
  @override
  Future<SwipeOut> swipe(SwipeIn body) async => const SwipeOut(matched: false);
}

void main() {
  Finder pass() => find.byWidgetPredicate(
        (w) => w is CircleButton && w.semanticLabel.startsWith('Pass on'),
      );

  double opacityOf(WidgetTester tester, Finder card) {
    final opacity = find.ancestor(of: card, matching: find.byType(Opacity)).first;
    return tester.widget<Opacity>(opacity).opacity;
  }

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  setUp(() async {
    await locator.reset();
    locator
      ..registerSingleton<DiscoveryRepository>(_FakeDiscovery())
      ..registerSingleton<SwipeRepository>(_FakeSwipe());
  });

  testWidgets('passing a card animates it out and the rest stay visible', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.build(false),
      home: Scaffold(body: SwipeScreen(onMatch: (_) {}, matchCount: 0, onOpenMatches: () {})),
    ));
    await settle(tester);
    // The list builds lazily; only the cards within the viewport exist.
    final before = find.byType(DiscoverCard).evaluate().length;
    expect(before, greaterThanOrEqualTo(2));
    expect(opacityOf(tester, find.byType(DiscoverCard).first), 1.0);

    await tester.tap(pass().first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    final leaving = find.byType(SizeTransition);
    expect(leaving, findsOneWidget);
    expect(tester.widget<SizeTransition>(leaving).sizeFactor.value, lessThan(1.0),
        reason: 'removal animation should be in progress');

    await settle(tester);
    expect(find.byType(SizeTransition), findsNothing);
    expect(find.byType(DiscoverCard).evaluate().length, greaterThanOrEqualTo(2));
    expect(opacityOf(tester, find.byType(DiscoverCard).first), 1.0,
        reason: 'remaining cards must be fully visible');
    expect(find.text('2 people near you'), findsOneWidget);
  });
}
