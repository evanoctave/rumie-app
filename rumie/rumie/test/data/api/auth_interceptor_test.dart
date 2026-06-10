import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/data/api/exceptions.dart';
import 'package:roomie/data/api/interceptors/auth_interceptor.dart';

import '../../fakes/fake_http_adapter.dart';
import '../../fakes/in_memory_token_store.dart';

({Dio main, Dio refresh, FakeHttpAdapter adapter}) _buildStack({
  required InMemoryTokenStore tokenStore,
  void Function()? onLogout,
}) {
  final adapter = FakeHttpAdapter();
  late Dio main;
  final refresh = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
    ..httpClientAdapter = adapter;
  main =
      Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
        ..httpClientAdapter = adapter
        ..interceptors.add(
          AuthInterceptor(
            tokenStore: tokenStore,
            refreshDio: refresh,
            mainDio: () => main,
            onLogout: onLogout,
          ),
        );
  return (main: main, refresh: refresh, adapter: adapter);
}

void main() {
  group('AuthInterceptor (V2 happy path)', () {
    test('401 → refresh → retry resolves with retried response', () async {
      final store = InMemoryTokenStore(access: 'old', refresh: 'r1');
      final stack = _buildStack(tokenStore: store);

      stack.adapter
        ..route('GET', '/me', const FakeResponse(statusCode: 401))
        ..route(
          'GET',
          '/me',
          const FakeResponse(statusCode: 200, body: {'id': 'u1'}),
        )
        ..route(
          'POST',
          '/auth/refresh',
          const FakeResponse(
            statusCode: 200,
            body: {'access': 'new-a', 'refresh': 'new-r'},
          ),
        );

      final resp = await stack.main.get<dynamic>('/me');

      expect(resp.statusCode, 200);
      expect(resp.data, {'id': 'u1'});
      expect(await store.readAccess(), 'new-a');
      expect(await store.readRefresh(), 'new-r');
      expect(stack.adapter.hits('POST', '/auth/refresh'), 1);
      expect(stack.adapter.hits('GET', '/me'), 2);
    });

    test('non-401 errors pass through untouched', () async {
      final store = InMemoryTokenStore(access: 'a', refresh: 'r');
      final stack = _buildStack(tokenStore: store);
      stack.adapter.route('GET', '/me', const FakeResponse(statusCode: 500));

      try {
        await stack.main.get<dynamic>('/me');
        fail('expected throw');
      } on DioException catch (e) {
        expect(e.response?.statusCode, 500);
      }
      expect(stack.adapter.hits('POST', '/auth/refresh'), 0);
    });
  });

  group('AuthInterceptor (V2 fail path)', () {
    test(
      'refresh fails → clears tokens, fires onLogout, raises UnauthorizedException',
      () async {
        final store = InMemoryTokenStore(access: 'old', refresh: 'r1');
        var logoutCalls = 0;
        final stack = _buildStack(
          tokenStore: store,
          onLogout: () => logoutCalls++,
        );

        stack.adapter
          ..route('GET', '/me', const FakeResponse(statusCode: 401))
          ..route(
            'POST',
            '/auth/refresh',
            const FakeResponse(statusCode: 401, body: {'detail': 'bad'}),
          );

        try {
          await stack.main.get<dynamic>('/me');
          fail('expected throw');
        } on DioException catch (e) {
          expect(e.error, isA<UnauthorizedException>());
        }

        expect(await store.readAccess(), isNull);
        expect(await store.readRefresh(), isNull);
        expect(logoutCalls, 1);
      },
    );

    test('no refresh token in store → fails fast, fires onLogout', () async {
      final store = InMemoryTokenStore(access: 'old'); // no refresh
      var logoutCalls = 0;
      final stack = _buildStack(
        tokenStore: store,
        onLogout: () => logoutCalls++,
      );

      stack.adapter.route('GET', '/me', const FakeResponse(statusCode: 401));

      try {
        await stack.main.get<dynamic>('/me');
        fail('expected throw');
      } on DioException catch (e) {
        expect(e.error, isA<UnauthorizedException>());
      }

      expect(logoutCalls, 1);
      expect(stack.adapter.hits('POST', '/auth/refresh'), 0);
    });
  });

  group('AuthInterceptor (V3 single-flight)', () {
    test('N concurrent 401s ⇒ exactly one refresh call', () async {
      final store = InMemoryTokenStore(access: 'old', refresh: 'r1');
      final stack = _buildStack(tokenStore: store);
      stack.adapter.responseDelay = const Duration(milliseconds: 40);

      for (var i = 0; i < 3; i++) {
        stack.adapter.route('GET', '/me', const FakeResponse(statusCode: 401));
      }
      for (var i = 0; i < 3; i++) {
        stack.adapter.route(
          'GET',
          '/me',
          const FakeResponse(statusCode: 200, body: {'ok': true}),
        );
      }
      stack.adapter.route(
        'POST',
        '/auth/refresh',
        const FakeResponse(
          statusCode: 200,
          body: {'access': 'new-a', 'refresh': 'new-r'},
        ),
      );

      final results = await Future.wait([
        stack.main.get<dynamic>('/me'),
        stack.main.get<dynamic>('/me'),
        stack.main.get<dynamic>('/me'),
      ]);

      expect(results.length, 3);
      for (final r in results) {
        expect(r.statusCode, 200);
      }
      expect(stack.adapter.hits('POST', '/auth/refresh'), 1);
      expect(await store.readAccess(), 'new-a');
    });
  });

  group('AuthInterceptor (V1 bearer + skip-paths)', () {
    test('attaches Bearer when token present', () async {
      final store = InMemoryTokenStore(access: 'tok-x', refresh: 'r');
      final stack = _buildStack(tokenStore: store);
      stack.adapter.route(
        'GET',
        '/me',
        const FakeResponse(statusCode: 200, body: {}),
      );

      Map<String, dynamic>? seenHeaders;
      stack.main.interceptors.add(
        InterceptorsWrapper(
          onRequest: (opts, h) {
            seenHeaders = Map.from(opts.headers);
            h.next(opts);
          },
        ),
      );

      await stack.main.get<dynamic>('/me');
      expect(seenHeaders?['Authorization'], 'Bearer tok-x');
    });

    test('skips Authorization on login path', () async {
      final store = InMemoryTokenStore(access: 'tok-x', refresh: 'r');
      final stack = _buildStack(tokenStore: store);
      stack.adapter.route(
        'POST',
        '/auth/login',
        const FakeResponse(statusCode: 200, body: {}),
      );

      Map<String, dynamic>? seenHeaders;
      stack.main.interceptors.add(
        InterceptorsWrapper(
          onRequest: (opts, h) {
            seenHeaders = Map.from(opts.headers);
            h.next(opts);
          },
        ),
      );

      await stack.main.post<dynamic>('/auth/login', data: {});
      expect(seenHeaders?.containsKey('Authorization'), isFalse);
    });
  });
}
