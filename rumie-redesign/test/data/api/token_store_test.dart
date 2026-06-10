import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/data/api/token_store.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel =
      MethodChannel('plugins.it_nomads.com/flutter_secure_storage');
  final Map<String, String?> backing = {};

  setUp(() {
    backing.clear();
    TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
      final args = (call.arguments as Map?) ?? const {};
      final key = args['key'] as String?;
      switch (call.method) {
        case 'write':
          backing[key!] = args['value'] as String?;
          return null;
        case 'read':
          return backing[key];
        case 'delete':
          backing.remove(key);
          return null;
        case 'containsKey':
          return backing.containsKey(key);
        case 'readAll':
          return Map<String, String?>.from(backing);
        case 'deleteAll':
          backing.clear();
          return null;
      }
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding
        .instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  group('SecureTokenStore (V4)', () {
    test('write then read returns same tokens under spec\'d keys', () async {
      const store = SecureTokenStore();
      await store.write(access: 'a-token', refresh: 'r-token');

      expect(await store.readAccess(), 'a-token');
      expect(await store.readRefresh(), 'r-token');
      expect(backing[SecureTokenStore.accessKey], 'a-token');
      expect(backing[SecureTokenStore.refreshKey], 'r-token');
    });

    test('clear removes both tokens', () async {
      const store = SecureTokenStore();
      await store.write(access: 'a', refresh: 'r');
      await store.clear();

      expect(await store.readAccess(), isNull);
      expect(await store.readRefresh(), isNull);
    });

    test('read returns null when no token written', () async {
      const store = SecureTokenStore();
      expect(await store.readAccess(), isNull);
      expect(await store.readRefresh(), isNull);
    });

    test('uses exact spec\'d storage keys', () {
      expect(SecureTokenStore.accessKey, 'rumie_access_token');
      expect(SecureTokenStore.refreshKey, 'rumie_refresh_token');
    });
  });
}
