import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:roomie/main.dart' as app;
import 'package:roomie/screens/home_screen.dart';
import 'package:roomie/widgets/discover_card.dart';
import 'package:roomie/widgets/match_tile.dart';
import 'package:roomie/widgets/ui/circle_button.dart';

/// Walks the main flows and screenshots mid-animation frames so motion
/// can be reviewed from a script. Run with:
///
///   flutter drive --driver=test_driver/integration_test.dart \
///     --target=integration_test/tour_test.dart -d DEVICE \
///     --dart-define=RUMIE_DEMO=true
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> shot(WidgetTester tester, String name, {int afterMs = 0}) async {
    if (afterMs > 0) {
      await tester.pump();
      await Future<void>.delayed(Duration(milliseconds: afterMs));
      await tester.pump();
    }
    await binding.takeScreenshot(name);
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    await Future<void>.delayed(const Duration(milliseconds: 900));
    await tester.pump();
  }

  Finder circle(String labelPrefix) => find.byWidgetPredicate(
        (w) => w is CircleButton && w.semanticLabel.startsWith(labelPrefix),
      );

  Finder tab(String label) => find.descendant(of: find.byType(FloatingNav), matching: find.text(label));
  Finder card(String name) => find.descendant(of: find.byType(DiscoverCard), matching: find.textContaining(name));
  Finder match(String name) => find.descendant(of: find.byType(MatchTile), matching: find.text(name));

  testWidgets('tour', (tester) async {
    app.main();
    await settle(tester);
    await settle(tester);
    await shot(tester, '01-discover');

    // Pass: card slides left and the gap collapses.
    await tester.tap(circle('Pass on Marcus'));
    await shot(tester, '02-pass-mid', afterMs: 160);
    await settle(tester);
    await shot(tester, '03-after-pass');

    // Connect: card slides right, toast drops in.
    await tester.tap(find.text('Connect').first);
    await shot(tester, '04-connect-mid', afterMs: 180);
    await shot(tester, '04b-connect-450', afterMs: 270);
    await shot(tester, '04c-connect-800', afterMs: 350);
    await shot(tester, '04d-connect-1300', afterMs: 500);
    await settle(tester);
    await shot(tester, '05-toast');
    await Future<void>.delayed(const Duration(milliseconds: 2600));
    await tester.pump();

    // Tab switch: capsule slides, page cross-fades.
    await tester.tap(tab('Matches'));
    await shot(tester, '06-tab-mid', afterMs: 120);
    await settle(tester);
    await shot(tester, '07-matches');

    // Open chat: avatar hero flight.
    await tester.tap(match('Jordan'));
    await shot(tester, '08-hero-mid', afterMs: 160);
    await settle(tester);
    await settle(tester);
    await shot(tester, '09-chat');

    await tester.enterText(find.byType(TextField), 'Hey Jordan! When are you free to see the place?');
    await tester.pump();
    await tester.tap(circle('Send'));
    await shot(tester, '10-bubble-mid', afterMs: 140);
    await settle(tester);
    await settle(tester);
    await settle(tester);
    await shot(tester, '11-chat-reply');

    await tester.tap(circle('Back'));
    await settle(tester);

    // Discover → profile: photo hero flight into the header.
    await tester.tap(tab('Discover'));
    await settle(tester);
    await tester.tap(card('Malik'));
    await shot(tester, '12-profile-hero-mid', afterMs: 200);
    await settle(tester);
    await shot(tester, '13-profile-view');
    await tester.drag(find.text('About'), const Offset(0, -260));
    await settle(tester);
    await shot(tester, '14-profile-scrolled');
    await tester.tap(circle('Back'));
    await settle(tester);

    // Listings: rings and bars animate in.
    await tester.tap(tab('Listings'));
    await shot(tester, '15-listings-mid', afterMs: 220);
    await settle(tester);
    await tester.tap(find.text('Room'));
    await settle(tester);
    await shot(tester, '16-listings-filtered');

    // Profile → create: segmented control thumb slides.
    await tester.tap(tab('Profile'));
    await settle(tester);
    await tester.tap(find.text('Create profile'));
    await settle(tester);
    await shot(tester, '17-create');
    await tester.drag(find.text('Basics'), const Offset(0, -520));
    await settle(tester);
    await tester.tap(find.text('Night owl').first);
    await shot(tester, '18-segment-mid', afterMs: 120);
    await settle(tester);
    await shot(tester, '19-segment-done');
  });
}
