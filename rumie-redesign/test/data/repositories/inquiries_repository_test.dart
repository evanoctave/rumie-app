import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/data/api/exceptions.dart';
import 'package:roomie/data/api/interceptors/error_interceptor.dart';
import 'package:roomie/data/models/inquiry_status.dart';
import 'package:roomie/data/repositories/inquiries_repository_impl.dart';

import '../../fakes/fake_http_adapter.dart';

({Dio dio, FakeHttpAdapter adapter}) _build() {
  final adapter = FakeHttpAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ErrorInterceptor());
  return (dio: dio, adapter: adapter);
}

void main() {
  group('InquiriesRepositoryImpl', () {
    test('list without filter parses InquiryOut[]', () async {
      final (:dio, :adapter) = _build();
      adapter.route('GET', '/inquiries',
          const FakeResponse(statusCode: 200, body: [
            {
              'id': 'inq1',
              'group_id': 'g1',
              'listing_id': 'l1',
              'status': 'pending',
            },
          ]));
      final repo = InquiriesRepositoryImpl(dio);

      final list = await repo.list();
      expect(list, hasLength(1));
      expect(list.first.status, InquiryStatus.pending);
    });

    test('accept returns open map', () async {
      final (:dio, :adapter) = _build();
      adapter.route('POST', '/inquiries/inq1/accept',
          const FakeResponse(statusCode: 201, body: {'conversation_id': 'c1'}));
      final repo = InquiriesRepositoryImpl(dio);

      final out = await repo.accept('inq1');
      expect(out['conversation_id'], 'c1');
    });

    test('reject returns void on 204', () async {
      final (:dio, :adapter) = _build();
      adapter.route('POST', '/inquiries/inq1/reject',
          const FakeResponse(statusCode: 204));
      final repo = InquiriesRepositoryImpl(dio);

      await repo.reject('inq1');
      expect(adapter.hits('POST', '/inquiries/inq1/reject'), 1);
    });

    test('422 → ValidationException', () async {
      final (:dio, :adapter) = _build();
      adapter.route(
        'GET',
        '/inquiries',
        const FakeResponse(
          statusCode: 422,
          body: {
            'detail': [
              {'loc': ['query', 'status_filter'], 'msg': 'bad', 'type': 't'},
            ],
          },
        ),
      );
      final repo = InquiriesRepositoryImpl(dio);

      try {
        await repo.list(status: InquiryStatus.pending);
        fail('expected throw');
      } on ValidationException catch (_) {
        // ok
      }
    });
  });
}
