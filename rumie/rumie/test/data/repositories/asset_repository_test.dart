import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/data/api/exceptions.dart';
import 'package:roomie/data/api/interceptors/auth_interceptor.dart';
import 'package:roomie/data/api/interceptors/error_interceptor.dart';
import 'package:roomie/data/models/asset_kind.dart';
import 'package:roomie/data/repositories/asset_repository_impl.dart';

import '../../fakes/fake_http_adapter.dart';
import '../../fakes/in_memory_token_store.dart';

const _presignBody = {
  'put_url': 'http://s3.test/upload/key1?sig=abc',
  'asset_url': 'http://cdn.test/key1',
  'key': 'key1',
  'expires_at': '2026-05-16T13:00:00Z',
};

void main() {
  group('AssetRepositoryImpl (V8)', () {
    test('upload: presign call carries bearer; PUT carries no Authorization',
        () async {
      // Single adapter shared by both dios — easier to assert hits.
      final adapter = FakeHttpAdapter()
        ..route('POST', '/uploads/presign',
            const FakeResponse(statusCode: 200, body: _presignBody))
        ..route('PUT', 'http://s3.test/upload/key1',
            const FakeResponse(statusCode: 200));

      // Main dio: has AuthInterceptor → attaches bearer.
      late Dio mainDio;
      final tokenStore = InMemoryTokenStore(access: 'tok-x', refresh: 'r');
      final refreshDio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
        ..httpClientAdapter = adapter;
      mainDio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
        ..httpClientAdapter = adapter
        ..interceptors.add(AuthInterceptor(
          tokenStore: tokenStore,
          refreshDio: refreshDio,
          mainDio: () => mainDio,
        ))
        ..interceptors.add(ErrorInterceptor());

      // PUT dio: bare, mirrors DioClient.createUploadPutDio (no auth).
      final putDio = Dio()..httpClientAdapter = adapter;

      // Spy to capture headers Dio actually sent on each request.
      String? presignAuth;
      String? putAuth;
      mainDio.interceptors.add(InterceptorsWrapper(onRequest: (opts, h) {
        if (opts.path == '/uploads/presign') {
          presignAuth = opts.headers['Authorization']?.toString();
        }
        h.next(opts);
      }));
      putDio.interceptors.add(InterceptorsWrapper(onRequest: (opts, h) {
        if (opts.method == 'PUT') {
          putAuth = opts.headers['Authorization']?.toString();
        }
        h.next(opts);
      }));

      final repo = AssetRepositoryImpl(mainDio, putDio);
      final url = await repo.upload(
        kind: AssetKind.avatar,
        bytes: Uint8List.fromList([1, 2, 3]),
        contentType: 'image/png',
      );

      expect(url, 'http://cdn.test/key1');
      expect(presignAuth, 'Bearer tok-x', reason: 'presign must carry bearer');
      expect(putAuth, isNull, reason: 'PUT must NOT carry Authorization (V8)');
      expect(adapter.hits('POST', '/uploads/presign'), 1);
      expect(adapter.hits('PUT', 'http://s3.test/upload/key1'), 1);
    });

    test('presign 422 → ValidationException; PUT never attempted', () async {
      final adapter = FakeHttpAdapter()
        ..route(
          'POST',
          '/uploads/presign',
          const FakeResponse(
            statusCode: 422,
            body: {
              'detail': [
                {'loc': ['body', 'content_type'], 'msg': 'unsupported', 'type': 't'},
              ],
            },
          ),
        );

      final mainDio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
        ..httpClientAdapter = adapter
        ..interceptors.add(ErrorInterceptor());
      final putDio = Dio()..httpClientAdapter = adapter;

      final repo = AssetRepositoryImpl(mainDio, putDio);

      try {
        await repo.upload(
          kind: AssetKind.avatar,
          bytes: Uint8List.fromList([1]),
          contentType: 'image/bmp',
        );
        fail('expected throw');
      } on ValidationException catch (e) {
        expect(e.fieldErrors, {'content_type': ['unsupported']});
      }

      expect(adapter.hits('PUT', 'http://s3.test/upload/key1'), 0);
    });

    test('PUT failure → NetworkException', () async {
      final adapter = FakeHttpAdapter()
        ..route('POST', '/uploads/presign',
            const FakeResponse(statusCode: 200, body: _presignBody))
        ..route('PUT', 'http://s3.test/upload/key1',
            const FakeResponse(statusCode: 500));

      final mainDio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
        ..httpClientAdapter = adapter
        ..interceptors.add(ErrorInterceptor());
      final putDio = Dio()..httpClientAdapter = adapter;

      final repo = AssetRepositoryImpl(mainDio, putDio);

      try {
        await repo.upload(
          kind: AssetKind.listingPhoto,
          bytes: Uint8List.fromList([1, 2, 3]),
          contentType: 'image/jpeg',
        );
        fail('expected throw');
      } on NetworkException catch (_) {
        // ok
      }
    });
  });
}
