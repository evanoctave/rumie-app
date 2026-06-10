import 'package:flutter/foundation.dart';

import '../di/locator.dart';
import '../domain/entities/lifestyle.dart';
import '../domain/entities/roommate_candidate.dart';
import '../domain/repositories/roommate_feed_repository.dart';

/// Quick-filter chips on the Discover tab.
enum DiscoverFilter {
  sameSchool('Same school'),
  budgetMatch('Budget match'),
  moveInSoon('Move-in soon'),
  petFriendly('Pet friendly'),
  clean('Clean'),
  nearCampus('Near campus');

  const DiscoverFilter(this.label);
  final String label;
}

/// Drives the Discover (swipe) feed.
class DiscoveryProvider extends ChangeNotifier {
  DiscoveryProvider({RoommateFeedRepository? repository})
    : _repo = repository ?? locator<RoommateFeedRepository>();

  final RoommateFeedRepository _repo;

  List<RoommateCandidate> _all = [];
  final Set<DiscoverFilter> _filters = {};
  bool _loading = true;

  bool get loading => _loading;
  Set<DiscoverFilter> get filters => _filters;

  List<RoommateCandidate> get visible => _all.where(_matchesFilters).toList();

  bool get hasMore => visible.isNotEmpty;
  RoommateCandidate? get current => hasMore ? visible.first : null;
  RoommateCandidate? get next {
    final v = visible;
    return v.length > 1 ? v[1] : null;
  }

  RoommateCandidate? get afterNext {
    final v = visible;
    return v.length > 2 ? v[2] : null;
  }

  Future<void> load() async {
    // No pre-notify: load() is kicked off from initState while the first
    // build is in flight, and _loading already starts true.
    if (!_loading) {
      _loading = true;
      notifyListeners();
    }
    _all = List.of(await _repo.discover());
    _loading = false;
    notifyListeners();
  }

  Future<void> like(RoommateCandidate candidate) async {
    await _repo.like(candidate.profile.id);
    _remove(candidate);
  }

  Future<void> pass(RoommateCandidate candidate) async {
    await _repo.pass(candidate.profile.id);
    _remove(candidate);
  }

  void toggleFilter(DiscoverFilter filter) {
    if (!_filters.remove(filter)) _filters.add(filter);
    notifyListeners();
  }

  void _remove(RoommateCandidate candidate) {
    _all.removeWhere((c) => c.profile.id == candidate.profile.id);
    notifyListeners();
  }

  bool _matchesFilters(RoommateCandidate c) {
    final p = c.profile;
    for (final f in _filters) {
      final ok = switch (f) {
        DiscoverFilter.sameSchool => c.distanceLabel == 'Same campus',
        DiscoverFilter.budgetMatch => c.compatibilityReasons.contains(
          'Your budgets overlap',
        ),
        DiscoverFilter.moveInSoon =>
          p.moveInDate.difference(DateTime.now()).inDays <= 90,
        DiscoverFilter.petFriendly => p.petPreference != PetPreference.noPets,
        DiscoverFilter.clean => p.cleanliness == CleanlinessLevel.veryTidy,
        DiscoverFilter.nearCampus => p.preferredDistanceFromCampusMiles <= 2,
      };
      if (!ok) return false;
    }
    return true;
  }
}
