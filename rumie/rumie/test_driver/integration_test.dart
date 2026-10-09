import 'dart:io';

import 'package:integration_test/integration_test_driver_extended.dart';

/// Saves screenshots taken by integration tests. Output directory comes
/// from RUMIE_SHOTS (defaults to build/tour). When RUMIE_UDID names a
/// booted simulator, the frame is captured host-side with simctl, which
/// is more faithful than the in-app snapshot.
Future<void> main() async {
  final dir = Directory(Platform.environment['RUMIE_SHOTS'] ?? 'build/tour')..createSync(recursive: true);
  final udid = Platform.environment['RUMIE_UDID'];
  await integrationDriver(
    onScreenshot: (name, bytes, [args]) async {
      final path = '${dir.path}/$name.png';
      if (udid != null && udid.isNotEmpty) {
        final result = Process.runSync('xcrun', ['simctl', 'io', udid, 'screenshot', path]);
        if (result.exitCode == 0) return true;
      }
      File(path).writeAsBytesSync(bytes);
      return true;
    },
  );
}
