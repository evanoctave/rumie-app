import 'package:flutter/material.dart';

import '../data/models/listing_out.dart';

class ListingsProvider extends ChangeNotifier {
  List<ListingOut> listings = [];
  bool loading = false;
}
