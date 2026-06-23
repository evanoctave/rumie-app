import '../../data/models/conversation_out.dart';
import '../../data/models/message_out.dart';

abstract class ConversationsRepository {
  Future<List<ConversationOut>> listConversations();
  Future<List<MessageOut>> listMessages(
    String convId, {
    int limit = 50,
    DateTime? before,
  });
  Future<MessageOut> sendMessage(String convId, String body);
}
