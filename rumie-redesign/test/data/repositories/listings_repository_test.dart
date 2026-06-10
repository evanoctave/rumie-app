import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/data/api/exceptions.dart';
import 'package:roomie/data/api/interceptors/error_interceptor.dart';
import 'package:roomie/data/models/listing_create.dart';
import 'package:roomie/data/models/listing_patch.dart';
import 'package:roomie/data/repositories/listings_repository_impl.dart';

import '../../fakes/fake_http_adapter.dart';

({Dio dio, FakeHttpAdapter adapter}) _build() {
  final adapter = FakeHttpAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ErrorInterceptor());
  return (dio: dio, adapter: adapter);
}

const _listingJson = {
  'id': 'l1',
  'landlord_id': 'll1',
  'title': 'Sunny 2BR',
  'description': 'great view',
  'rent': 1500,
  'location': 'SoMa',
  'photo_urls': <String>[],
};

void main() {
  group('ListingsRepositoryImpl', () {
    test('create happy', () async {
      final (:dio, :adapter) = _build();
      adapter.route('POST', '/listings',
          const FakeResponse(statusCode: 201, body: _listingJson));
      final repo = ListingsRepositoryImpl(dio);

      final l = await repo.create(const ListingCreate(
        title: 'Sunny 2BR',
        rent: 1500,
        location: 'SoMa',
      ));
      expect(l.id, 'l1');
    });

    test('get builds /listings/<id>', () async {
      final (:dio, :adapter) = _build();
      adapter.route('GET', '/listings/l1',
          const FakeResponse(statusCode: 200, body: _listingJson));
      final repo = ListingsRepositoryImpl(dio);

      final l = await repo.get('l1');
      expect(l.id, 'l1');
      expect(adapter.hits('GET', '/listings/l1'), 1);
    });

    test('patch sends partial body', () async {
      final (:dio, :adapter) = _build();
      adapter.route('PATCH', '/listings/l1',
          const FakeResponse(statusCode: 200, body: _listingJson));
      final repo = ListingsRepositoryImpl(dio);

      await repo.patch('l1', const ListingPatch(rent: 2000));
      expect(adapter.hits('PATCH', '/listings/l1'), 1);
    });

    test('delete returns void on 204', () async {
      final (:dio, :adapter) = _build();
      adapter.route(
          'DELETE', '/listings/l1', const FakeResponse(statusCode: 204));
      final repo = ListingsRepositoryImpl(dio);

      await repo.delete('l1');
      expect(adapter.hits('DELETE', '/listings/l1'), 1);
    });

    test('422 path → ValidationException', () async {
      final (:dio, :adapter) = _build();
      adapter.route(
        'POST',
        '/listings',
        const FakeResponse(
          statusCode: 422,
          body: {
            'detail': [
              {'loc': ['body', 'rent'], 'msg': 'must be ≥0', 'type': 't'},
            ],
          },
        ),
      );
      final repo = ListingsRepositoryImpl(dio);

      try {
        await repo.create(const ListingCreate(
          title: 't',
          rent: -1,
          location: 'x',
        ));
        fail('expected throw');
      } on ValidationException catch (e) {
        expect(e.fieldErrors.containsKey('rent'), isTrue);
      }
    });
  });
}
