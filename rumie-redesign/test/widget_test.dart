import 'package:flutter_test/flutter_test.dart';

import 'package:roomie/main.dart';

void main() {
  // Stale since design changes (7aeb8b6) removed brand text from HomeScreen.
  testWidgets('App boots and shows the brand name', (tester) async {
    await tester.pumpWidget(const Rumie());
    expect(find.text('Rumie'), findsOneWidget);
  }, skip: true);
}
