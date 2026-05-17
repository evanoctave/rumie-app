import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/data/api/exceptions.dart';
import 'package:roomie/data/api/interceptors/error_interceptor.dart';
import 'package:roomie/data/repositories/conversations_repository_impl.dart';

import '../../fakes/fake_http_adapter.dart';

({Dio dio, FakeHttpAdapter adapter}) _build() {
  final adapter = FakeHttpAdapter();
  final dio = Dio(BaseOptions(baseUrl: 'http://test/api/v1'))
    ..httpClientAdapter = adapter
    ..interceptors.add(ErrorInterceptor());
  return (dio: dio, adapter: adapter);
}

void main() {
  group('ConversationsRepositoryImpl', () {
    test('listConversations parses ConversationOut[]', () async {
      final (:dio, :adapter) = _build();
      adapter.route('GET', '/conversations',
          const FakeResponse(statusCode: 200, body: [
            {
              'id': 'c1',
              'type': 'internal_group',
              'participants': ['u1'],
              'group_id': 'g1',
              'listing_id': null,
            },
          ]));
      final repo = ConversationsRepositoryImpl(dio);

      final list = await repo.listConversations();
      expect(list, hasLength(1));
      expect(list.first.id, 'c1');
    });

    test('listMessages with before parses MessageOut[]', () async {
      final (:dio, :adapter) = _build();
      adapter.route('GET', '/conversations/c1/messages',
          const FakeResponse(statusCode: 200, body: [
            {
              'id': 'm1',
              'conversation_id': 'c1',
              'sender_id': 'u1',
              'body': 'hi',
              'ts': '2026-05-01T00:00:00.000Z',
            },
          ]));
      final repo = ConversationsRepositoryImpl(dio);

      final list = await repo.listMessages(
        'c1',
        limit: 20,
        before: DateTime.utc(2026, 5, 16),
      );
      expect(list, hasLength(1));
      expect(list.first.body, 'hi');
    });

    test('sendMessage returns MessageOut', () async {
      final (:dio, :adapter) = _build();
      adapter.route('POST', '/conversations/c1/messages',
          const FakeResponse(statusCode: 201, body: {
            'id': 'm2',
            'conversation_id': 'c1',
            'sender_id': 'u1',
            'body': 'sent',
            'ts': '2026-05-16T12:00:00.000Z',
          }));
      final repo = ConversationsRepositoryImpl(dio);

      final m = await repo.sendMessage('c1', 'sent');
      expect(m.id, 'm2');
    });

    test('422 on send → ValidationException', () async {
      final (:dio, :adapter) = _build();
      adapter.route(
        'POST',
        '/conversations/c1/messages',
        const FakeResponse(
          statusCode: 422,
          body: {
            'detail': [
              {'loc': ['body', 'body'], 'msg': 'too long', 'type': 't'},
            ],
          },
        ),
      );
      final repo = ConversationsRepositoryImpl(dio);

      try {
        await repo.sendMessage('c1', 'a' * 5000);
        fail('expected throw');
      } on ValidationException catch (e) {
        expect(e.fieldErrors.containsKey('body'), isTrue);
      }
    });
  });
}
