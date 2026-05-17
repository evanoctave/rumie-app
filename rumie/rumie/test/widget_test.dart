import 'package:flutter_test/flutter_test.dart';

import 'package:roomie/main.dart';

void main() {
  testWidgets('App boots and shows the brand name', (tester) async {
    await tester.pumpWidget(const Rumie());
    expect(find.text('Rumie'), findsOneWidget);
  });
}
