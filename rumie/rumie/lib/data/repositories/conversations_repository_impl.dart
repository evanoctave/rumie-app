import 'package:dio/dio.dart';

import '../../domain/repositories/conversations_repository.dart';
import '../models/conversation_out.dart';
import '../models/message_in.dart';
import '../models/message_out.dart';
import 'repository_helpers.dart';

class ConversationsRepositoryImpl implements ConversationsRepository {
  final Dio _dio;

  ConversationsRepositoryImpl(this._dio);

  @override
  Future<List<ConversationOut>> listConversations() => callApi(() async {
        final r = await _dio.get<dynamic>('/conversations');
        final list = r.data as List<dynamic>;
        return list
            .map((e) => ConversationOut.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  @override
  Future<List<MessageOut>> listMessages(
    String convId, {
    int limit = 50,
    DateTime? before,
  }) =>
      callApi(() async {
        final r = await _dio.get<dynamic>(
          '/conversations/$convId/messages',
          queryParameters: {
            'limit': limit,
            if (before != null) 'before': before.toUtc().toIso8601String(),
          },
        );
        final list = r.data as List<dynamic>;
        return list
            .map((e) => MessageOut.fromJson(e as Map<String, dynamic>))
            .toList();
      });

  @override
  Future<MessageOut> sendMessage(String convId, String body) =>
      callApi(() async {
        final r = await _dio.post<dynamic>(
          '/conversations/$convId/messages',
          data: MessageIn(body: body).toJson(),
        );
        return MessageOut.fromJson(r.data as Map<String, dynamic>);
      });
}
