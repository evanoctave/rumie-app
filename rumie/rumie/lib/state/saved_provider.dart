import 'package:flutter/foundation.dart';

import '../di/locator.dart';
import '../domain/entities/housing_listing.dart';
import '../domain/entities/roommate_candidate.dart';
import '../domain/repositories/housing_repository.dart';
import '../domain/repositories/roommate_feed_repository.dart';

/// Saved roommates + saved listings. In-memory for now; persists through
/// `POST /roommates/{id}/save` / `POST /housing/listings/{id}/save` later.
class SavedProvider extends ChangeNotifier {
  SavedProvider({
    RoommateFeedRepository? feedRepository,
    HousingRepository? housingRepository,
  }) : _feedRepo = feedRepository ?? locator<RoommateFeedRepository>(),
       _housingRepo = housingRepository ?? locator<HousingRepository>();

  final RoommateFeedRepository _feedRepo;
  final HousingRepository _housingRepo;

  final Set<String> _roommateIds = {};
  final Set<String> _listingIds = {};

  bool isRoommateSaved(String id) => _roommateIds.contains(id);
  bool isListingSaved(String id) => _listingIds.contains(id);
  int get count => _roommateIds.length + _listingIds.length;

  void toggleRoommate(String id) {
    if (!_roommateIds.remove(id)) _roommateIds.add(id);
    notifyListeners();
  }

  void toggleListing(String id) {
    if (!_listingIds.remove(id)) _listingIds.add(id);
    notifyListeners();
  }

  Future<List<RoommateCandidate>> savedRoommates() async {
    final out = <RoommateCandidate>[];
    for (final id in _roommateIds) {
      final c = await _feedRepo.byId(id);
      if (c != null) out.add(c);
    }
    return out;
  }

  Future<List<HousingListing>> savedListings() async {
    final out = <HousingListing>[];
    for (final id in _listingIds) {
      final l = await _housingRepo.byId(id);
      if (l != null) out.add(l);
    }
    return out;
  }
}
