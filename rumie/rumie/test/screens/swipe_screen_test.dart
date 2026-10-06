import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:roomie/di/locator.dart';
import 'package:roomie/domain/entities/entities.dart';
import 'package:roomie/domain/errors/api_exception.dart';
import 'package:roomie/domain/repositories/discovery_repository.dart';
import 'package:roomie/domain/repositories/swipe_repository.dart';
import 'package:roomie/screens/swipe_screen.dart';

class _FakeDiscovery implements DiscoveryRepository {
  Future<List<GroupOut>> Function() groups;
  _FakeDiscovery(this.groups);

  @override
  Future<List<GroupOut>> discoverGroups({int limit = 20}) => groups();

  @override
  Future<List<ListingOut>> discoverListings({int limit = 20}) async => [];
}

class _FakeSwipe implements SwipeRepository {
  final List<SwipeIn> calls = [];
  SwipeOut result = const SwipeOut(matched: false);

  @override
  Future<SwipeOut> swipe(SwipeIn body) async {
    calls.add(body);
    return result;
  }
}

GroupOut _g(String id, {List<String> tags = const []}) => GroupOut(
      id: id,
      adminId: 'a-$id',
      members: ['a-$id'],
      preferences: Preferences(budget: 1000, tags: tags),
      capacity: 2,
    );

void main() {
  late _FakeSwipe swipe;
  final matched = <RoommateCandidate>[];

  setUpAll(() => GoogleFonts.config.allowRuntimeFetching = false);

  Future<void> pumpScreen(
    WidgetTester tester,
    Future<List<GroupOut>> Function() groups,
  ) async {
    await locator.reset();
    swipe = _FakeSwipe();
    locator
      ..registerSingleton<DiscoveryRepository>(_FakeDiscovery(groups))
      ..registerSingleton<SwipeRepository>(swipe);
    matched.clear();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SwipeScreen(
          onMatch: matched.add,
          matchCount: 0,
          onOpenMatches: () {},
        ),
      ),
    ));
  }

  // flutter_animate has looping animations, so settle with fixed pumps.
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('loading → deck from DiscoveryRepository', (tester) async {
    final gate = Completer<List<GroupOut>>();
    await pumpScreen(tester, () => gate.future);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    gate.complete([_g('g1', tags: ['Gamer']), _g('g2')]);
    await settle(tester);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Solo rumie'), findsOneWidget);
    expect(find.text('Gamer'), findsOneWidget);
    expect(find.text('\$1000/mo'), findsOneWidget);
  });

  testWidgets('empty discovery → existing empty state', (tester) async {
    await pumpScreen(tester, () async => []);
    await settle(tester);
    expect(find.text("You've seen everyone"), findsOneWidget);
  });

  testWidgets('error → user-safe message + retry reloads', (tester) async {
    var attempts = 0;
    await pumpScreen(tester, () async {
      attempts++;
      if (attempts == 1) throw const NetworkException();
      return [_g('g1')];
    });
    await settle(tester);
    expect(find.text(const NetworkException().message), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await settle(tester);
    expect(attempts, 2);
    expect(find.text('Solo rumie'), findsOneWidget);
  });

  testWidgets('Like posts a right swipe; match dialog only when matched',
      (tester) async {
    await pumpScreen(tester, () async => [_g('g1'), _g('g2')]);
    await settle(tester);

    await tester.tap(find.text('Like'));
    await settle(tester);
    expect(swipe.calls.single.targetId, 'g1');
    expect(swipe.calls.single.direction, SwipeDirection.right);
    expect(swipe.calls.single.targetType, SwipeTargetType.group);
    expect(find.text("It's a Match!"), findsNothing);
    expect(matched, isEmpty);

    swipe.result = const SwipeOut(matched: true, merge: {'group_id': 'gx'});
    await tester.tap(find.text('Like'));
    await settle(tester);
    expect(swipe.calls.last.targetId, 'g2');
    expect(find.text("It's a Match!"), findsOneWidget);
    expect(matched.single.id, 'g2');
  });

  testWidgets('Pass posts a left swipe', (tester) async {
    await pumpScreen(tester, () async => [_g('g1')]);
    await settle(tester);
    await tester.tap(find.text('Pass'));
    await settle(tester);
    expect(swipe.calls.single.direction, SwipeDirection.left);
    expect(find.text("You've seen everyone"), findsOneWidget);
  });
}
