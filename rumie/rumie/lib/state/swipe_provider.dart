import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class SwipeProvider extends ChangeNotifier {
  final AuthService authService;

  SwipeProvider(this.authService);

  Future<dynamic> swipe({
    required String targetId,
    required String targetType,
    required String direction,
  }) async {
    final api = await authService.authorizedApi();

    return api.postSwipe(
      targetId: targetId,
      targetType: targetType,
      direction: direction,
    );
  }
}
