import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// V10 / V17: presentation code depends on `lib/domain/`, never on
/// `lib/data/` (and therefore never on Dio). Enforced here because the
/// analyzer has no built-in layer rule.
void main() {
  final importRe = RegExp(r'''^\s*(import|export)\s+['"]([^'"]+)['"]''');

  for (final dir in ['lib/screens', 'lib/widgets', 'lib/state']) {
    test('$dir does not import lib/data or dio', () {
      final offenders = <String>[];
      for (final f in Directory(dir)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.dart'))) {
        for (final line in f.readAsLinesSync()) {
          final m = importRe.firstMatch(line);
          if (m == null) continue;
          final uri = m.group(2)!;
          if (uri.contains('/data/') ||
              uri.startsWith('data/') ||
              uri.startsWith('package:roomie/data/') ||
              uri.startsWith('package:dio/')) {
            offenders.add('${f.path}: $uri');
          }
        }
      }
      expect(offenders, isEmpty);
    });
  }

  test('legacy mock data and models are gone (T16)', () {
    for (final p in [
      'lib/data/sample_data.dart',
      'lib/models/roommate.dart',
      'lib/models/trait.dart',
      'lib/api/api_client.dart',
    ]) {
      expect(File(p).existsSync(), isFalse, reason: p);
    }
  });
}
