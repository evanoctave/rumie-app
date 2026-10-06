import 'package:flutter/material.dart';

import '../domain/entities/entities.dart';

class ListingsProvider extends ChangeNotifier {
  List<ListingOut> listings = [];
  bool loading = false;
}
