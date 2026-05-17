import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/data/api/interceptors/error_interceptor.dart';
import 'package:roomie/data/models/swipe_direction.dart';
import 'package:roomie/data/models/swipe_in.dart';
import 'package:roomie/data/models/swipe_target_type.dart';
import 'package:roomie/data/repositories/swipe_repository_impl.dart';

import '../../fakes/fake_http_adapter.dart';

({Dio dio, FakeHttpAdapter adapter}) _build() {
  final adapter = FakeHttpAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ErrorInterceptor());
  return (dio: dio, adapter: adapter);
}

void main() {
  group('SwipeRepositoryImpl (V16)', () {
    test('returns matched=true with merge payload', () async {
      final (:dio, :adapter) = _build();
      adapter.route('POST', '/swipes',
          const FakeResponse(statusCode: 200, body: {
            'matched': true,
            'merge': {'group_id': 'g1', 'capacity': 4},
          }));
      final repo = SwipeRepositoryImpl(dio);

      final out = await repo.swipe(const SwipeIn(
        targetId: 't1',
        targetType: SwipeTargetType.group,
        direction: SwipeDirection.right,
      ));
      expect(out.matched, isTrue);
      expect(out.merge?['group_id'], 'g1');
      expect(out.inquiry, isNull);
    });

    test('returns matched=true with inquiry payload (landlord path)',
        () async {
      final (:dio, :adapter) = _build();
      adapter.route('POST', '/swipes',
          const FakeResponse(statusCode: 200, body: {
            'matched': true,
            'inquiry': {'id': 'inq1', 'status': 'pending'},
          }));
      final repo = SwipeRepositoryImpl(dio);

      final out = await repo.swipe(const SwipeIn(
        targetId: 't1',
        targetType: SwipeTargetType.listing,
        direction: SwipeDirection.right,
      ));
      expect(out.matched, isTrue);
      expect(out.inquiry?['id'], 'inq1');
      expect(out.merge, isNull);
    });

    test('returns matched=false with reason', () async {
      final (:dio, :adapter) = _build();
      adapter.route('POST', '/swipes',
          const FakeResponse(statusCode: 200, body: {
            'matched': false,
            'reason': 'already_swiped',
          }));
      final repo = SwipeRepositoryImpl(dio);

      final out = await repo.swipe(const SwipeIn(
        targetId: 't1',
        targetType: SwipeTargetType.group,
        direction: SwipeDirection.left,
      ));
      expect(out.matched, isFalse);
      expect(out.reason, 'already_swiped');
    });
  });
}
