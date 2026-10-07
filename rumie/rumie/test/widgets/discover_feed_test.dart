import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roomie/screens/home_screen.dart';
import 'package:roomie/theme/app_theme.dart';
import 'package:roomie/widgets/discover_card.dart';
import 'package:roomie/widgets/ui/circle_button.dart';

void main() {
  Finder pass(String name) => find.byWidgetPredicate(
        (w) => w is CircleButton && w.semanticLabel == 'Pass on $name',
      );

  double opacityOf(WidgetTester tester, Finder card) {
    final opacity = find.ancestor(of: card, matching: find.byType(Opacity)).first;
    return tester.widget<Opacity>(opacity).opacity;
  }

  testWidgets('passing a card removes it and the rest stay visible', (tester) async {
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(theme: AppTheme.build(false), home: const HomeScreen()));
    await tester.pumpAndSettle();
    expect(find.byType(DiscoverCard), findsWidgets);
    expect(opacityOf(tester, find.byType(DiscoverCard).first), 1.0);

    await tester.tap(pass('Marcus'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    final leaving = find.byType(SizeTransition);
    expect(leaving, findsOneWidget);
    final size = tester.widget<SizeTransition>(leaving).sizeFactor.value;
    expect(size, lessThan(1.0), reason: 'removal animation should be in progress');

    await tester.pumpAndSettle();
    expect(find.byType(SizeTransition), findsNothing);
    expect(find.textContaining('Marcus'), findsNothing);
    final first = find.byType(DiscoverCard).first;
    expect(first, findsOneWidget);
    expect(opacityOf(tester, first), 1.0, reason: 'remaining cards must be fully visible');
    expect(find.text('4 people near you'), findsOneWidget);
  });
}
