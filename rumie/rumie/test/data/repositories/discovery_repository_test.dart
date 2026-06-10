import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/data/api/exceptions.dart';
import 'package:roomie/data/api/interceptors/error_interceptor.dart';
import 'package:roomie/data/repositories/discovery_repository_impl.dart';

import '../../fakes/fake_http_adapter.dart';

({Dio dio, FakeHttpAdapter adapter}) _build() {
  final adapter = FakeHttpAdapter();
  final dio =
      Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
        ..httpClientAdapter = adapter
        ..interceptors.add(ErrorInterceptor());
  return (dio: dio, adapter: adapter);
}

void main() {
  group('DiscoveryRepositoryImpl', () {
    test('discoverGroups returns parsed list', () async {
      final (:dio, :adapter) = _build();
      adapter.route(
        'GET',
        '/discovery/groups',
        const FakeResponse(
          statusCode: 200,
          body: [
            {
              'id': 'g1',
              'admin_id': 'a1',
              'members': ['m1'],
              'preferences': {'tags': []},
              'capacity': 3,
            },
          ],
        ),
      );
      final repo = DiscoveryRepositoryImpl(dio);

      final list = await repo.discoverGroups(limit: 10);
      expect(list, hasLength(1));
      expect(list.first.id, 'g1');
    });

    test('discoverListings returns parsed list', () async {
      final (:dio, :adapter) = _build();
      adapter.route(
        'GET',
        '/discovery/listings',
        const FakeResponse(
          statusCode: 200,
          body: [
            {
              'id': 'l1',
              'landlord_id': 'll1',
              'title': 't',
              'description': '',
              'rent': 1000,
              'location': 'x',
              'photo_urls': <String>[],
            },
          ],
        ),
      );
      final repo = DiscoveryRepositoryImpl(dio);

      final list = await repo.discoverListings();
      expect(list, hasLength(1));
      expect(list.first.rent, 1000);
    });

    test('422 → ValidationException', () async {
      final (:dio, :adapter) = _build();
      adapter.route(
        'GET',
        '/discovery/groups',
        const FakeResponse(
          statusCode: 422,
          body: {
            'detail': [
              {
                'loc': ['query', 'limit'],
                'msg': 'too big',
                'type': 't',
              },
            ],
          },
        ),
      );
      final repo = DiscoveryRepositoryImpl(dio);

      try {
        await repo.discoverGroups(limit: 9999);
        fail('expected throw');
      } on ValidationException catch (e) {
        expect(e.fieldErrors, {
          'limit': ['too big'],
        });
      }
    });
  });
}
