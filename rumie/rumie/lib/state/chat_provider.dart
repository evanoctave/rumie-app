import 'package:flutter/material.dart';

import '../api/api_models.dart';
import '../services/auth_service.dart';

class ChatProvider extends ChangeNotifier {
  final AuthService authService;

  ChatProvider(this.authService);

  List<dynamic> messages = [];

  bool loading = false;

  Future<void> loadMessages(String conversationId) async {
    loading = true;
    notifyListeners();

    try {
      final api = await authService.authorizedApi();

      messages = await api.listMessages(conversationId);
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    final api = await authService.authorizedApi();

    final message = await api.sendMessage(
      conversationId: conversationId,
      body: body,
    );

    messages.add(message);

    notifyListeners();
  }
}
