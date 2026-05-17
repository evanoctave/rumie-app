import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/data/api/exceptions.dart';
import 'package:roomie/data/api/interceptors/error_interceptor.dart';
import 'package:roomie/data/models/gender.dart';
import 'package:roomie/data/models/login_in.dart';
import 'package:roomie/data/models/register_in.dart';
import 'package:roomie/data/models/role.dart';
import 'package:roomie/data/repositories/auth_repository_impl.dart';

import '../../fakes/fake_http_adapter.dart';
import '../../fakes/in_memory_token_store.dart';

({Dio dio, FakeHttpAdapter adapter}) _build() {
  final adapter = FakeHttpAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ErrorInterceptor());
  return (dio: dio, adapter: adapter);
}

void main() {
  group('AuthRepositoryImpl.login (V14)', () {
    test('happy path returns tokens and persists them', () async {
      final (:dio, :adapter) = _build();
      final store = InMemoryTokenStore();
      adapter.route('POST', '/auth/login',
          const FakeResponse(statusCode: 200, body: {'access': 'A', 'refresh': 'R'}));
      final repo = AuthRepositoryImpl(dio, store);

      final tokens = await repo.login(
        const LoginIn(email: 'a@b.com', password: 'pw12345678'),
      );

      expect(tokens.access, 'A');
      expect(tokens.refresh, 'R');
      expect(await store.readAccess(), 'A');
      expect(await store.readRefresh(), 'R');
    });

    test('422 → ValidationException, tokens not persisted', () async {
      final (:dio, :adapter) = _build();
      final store = InMemoryTokenStore();
      adapter.route(
        'POST',
        '/auth/login',
        const FakeResponse(
          statusCode: 422,
          body: {
            'detail': [
              {'loc': ['body', 'email'], 'msg': 'bad email', 'type': 'value_error'},
            ],
          },
        ),
      );
      final repo = AuthRepositoryImpl(dio, store);

      try {
        await repo.login(const LoginIn(email: 'x', password: 'y'));
        fail('expected throw');
      } on ValidationException catch (e) {
        expect(e.fieldErrors, {'email': ['bad email']});
      }
      expect(await store.readAccess(), isNull);
    });
  });

  group('AuthRepositoryImpl.register (V14)', () {
    test('persists tokens from RegisterOut.tokens', () async {
      final (:dio, :adapter) = _build();
      final store = InMemoryTokenStore();
      adapter.route('POST', '/auth/register',
          const FakeResponse(statusCode: 201, body: {
            'user': {
              'id': 'u1',
              'email': 'a@b.com',
              'phone': null,
              'role': 'rumie',
              'age': 24,
              'gender': 'female',
              'profile_photo_url': null,
            },
            'tokens': {'access': 'A2', 'refresh': 'R2'},
          }));
      final repo = AuthRepositoryImpl(dio, store);

      final out = await repo.register(const RegisterIn(
        email: 'a@b.com',
        password: 'pw12345678',
        role: Role.rumie,
        age: 24,
        gender: Gender.female,
      ));

      expect(out.user.id, 'u1');
      expect(await store.readAccess(), 'A2');
      expect(await store.readRefresh(), 'R2');
    });
  });

  group('AuthRepositoryImpl.logout (V15)', () {
    test('clears token store; no HTTP call made', () async {
      final (:dio, :adapter) = _build();
      final store = InMemoryTokenStore(access: 'a', refresh: 'r');
      final repo = AuthRepositoryImpl(dio, store);

      await repo.logout();

      expect(await store.readAccess(), isNull);
      expect(await store.readRefresh(), isNull);
      // No routes ever hit (no calls to adapter).
      expect(adapter.hits('POST', '/auth/logout'), 0);
    });
  });

  group('AuthRepositoryImpl.me', () {
    test('parses UserOut from /auth/me', () async {
      final (:dio, :adapter) = _build();
      adapter.route('GET', '/auth/me',
          const FakeResponse(statusCode: 200, body: {
            'id': 'u1',
            'email': 'a@b.com',
            'phone': '+1',
            'role': 'landlord',
            'age': 30,
            'gender': 'male',
            'profile_photo_url': 'http://x/p.jpg',
          }));
      final repo = AuthRepositoryImpl(dio, InMemoryTokenStore());

      final me = await repo.me();
      expect(me.id, 'u1');
      expect(me.role, Role.landlord);
      expect(me.phone, '+1');
    });
  });
}
