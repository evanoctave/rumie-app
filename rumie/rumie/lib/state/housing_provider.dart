import 'package:flutter/foundation.dart';

import '../di/locator.dart';
import '../domain/entities/housing_listing.dart';
import '../domain/repositories/housing_repository.dart';

/// Quick-filter chips on the Housing tab.
enum HousingFilter {
  nearCampus('Near campus'),
  under1200('Under \$1,200'),
  privateRoom('Private room'),
  petFriendly('Pet friendly'),
  furnished('Furnished'),
  verified('Verified');

  const HousingFilter(this.label);
  final String label;
}

/// Drives the Housing browse tab.
class HousingProvider extends ChangeNotifier {
  HousingProvider({HousingRepository? repository})
    : _repo = repository ?? locator<HousingRepository>();

  final HousingRepository _repo;

  List<HousingListing> _listings = [];
  final Set<HousingFilter> _filters = {};
  bool _loading = true;

  bool get loading => _loading;
  Set<HousingFilter> get filters => _filters;

  List<HousingListing> get listings {
    return _listings.where((l) {
      for (final f in _filters) {
        final ok = switch (f) {
          HousingFilter.nearCampus => l.distanceFromCampusMiles <= 1.5,
          HousingFilter.under1200 => l.priceMonthly < 1200,
          HousingFilter.privateRoom =>
            l.availableRooms >= 1 &&
                l.type != 'Studio' &&
                !l.title.toLowerCase().contains('shared room'),
          HousingFilter.petFriendly => l.petPolicy.toLowerCase() != 'no pets',
          HousingFilter.furnished => l.furnished,
          HousingFilter.verified => l.verified,
        };
        if (!ok) return false;
      }
      return true;
    }).toList();
  }

  Future<void> load() async {
    // No pre-notify: load() is kicked off from initState while the first
    // build is in flight, and _loading already starts true.
    if (!_loading) {
      _loading = true;
      notifyListeners();
    }
    _listings = await _repo.browse();
    _loading = false;
    notifyListeners();
  }

  void toggleFilter(HousingFilter filter) {
    if (!_filters.remove(filter)) _filters.add(filter);
    notifyListeners();
  }
}
