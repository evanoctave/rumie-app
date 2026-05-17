import 'package:flutter/material.dart';

import '../api/api_models.dart';
import '../services/auth_service.dart';

class ListingsProvider extends ChangeNotifier {
  final AuthService authService;

  ListingsProvider(this.authService);

  List<ListingOut> listings = [];

  bool loading = false;

  Future<void> loadListings() async {
    loading = true;
    notifyListeners();

    try {
      final api = await authService.authorizedApi();

      listings = await api.discoverListings();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
