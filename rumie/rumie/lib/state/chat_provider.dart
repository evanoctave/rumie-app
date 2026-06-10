import 'package:flutter/material.dart';

import '../data/models/message_out.dart';
import '../di/locator.dart';
import '../domain/repositories/conversations_repository.dart';

class ChatProvider extends ChangeNotifier {
  List<MessageOut> messages = [];
  bool loading = false;

  Future<void> loadMessages(String conversationId) async {
    loading = true;
    notifyListeners();
    try {
      messages = await locator<ConversationsRepository>().listMessages(
        conversationId,
      );
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    final msg = await locator<ConversationsRepository>().sendMessage(
      conversationId,
      body,
    );
    messages.add(msg);
    notifyListeners();
  }
}
