import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:roomie/data/mock/mock_housing_repository.dart';
import 'package:roomie/data/mock/mock_roommate_feed_repository.dart';
import 'package:roomie/data/mock/mock_roommate_group_repository.dart';
import 'package:roomie/screens/home_screen.dart';
import 'package:roomie/state/discovery_provider.dart';
import 'package:roomie/state/group_provider.dart';
import 'package:roomie/state/housing_provider.dart';
import 'package:roomie/state/matches_provider.dart';
import 'package:roomie/state/profile_provider.dart';
import 'package:roomie/state/saved_provider.dart';
import 'package:roomie/state/theme_provider.dart';

Widget _appShell() {
  final feedRepo = MockRoommateFeedRepository();
  final housingRepo = MockHousingRepository();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ChangeNotifierProvider(
        create: (_) => DiscoveryProvider(repository: feedRepo),
      ),
      ChangeNotifierProvider(
        create: (_) => HousingProvider(repository: housingRepo),
      ),
      ChangeNotifierProvider(create: (_) => MatchesProvider()),
      ChangeNotifierProvider(
        create:
            (_) => SavedProvider(
              feedRepository: feedRepo,
              housingRepository: housingRepo,
            ),
      ),
      ChangeNotifierProvider(
        create: (_) => GroupProvider(repository: MockRoommateGroupRepository()),
      ),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  testWidgets('app shell boots into Discover with all five tabs', (
    tester,
  ) async {
    await tester.pumpWidget(_appShell());
    // Let the mock feed resolve and entrance animations play out.
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Find your people'), findsOneWidget);
    for (final tab in ['Discover', 'Housing', 'Matches', 'Saved', 'Profile']) {
      expect(find.text(tab), findsOneWidget);
    }
  });

  testWidgets('Housing tab shows the browse feed', (tester) async {
    await tester.pumpWidget(_appShell());
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 700));

    await tester.tap(find.text('Housing'));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.text('Find your place'), findsOneWidget);

    // Flush stray one-shot animation delay timers before teardown.
    await tester.pump(const Duration(seconds: 2));
  });
}
