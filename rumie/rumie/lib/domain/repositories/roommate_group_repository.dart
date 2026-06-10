import '../entities/roommate_group.dart';

/// Roommate-group data source.
///
/// Mock-backed today (`MockRoommateGroupRepository`); swaps to
/// `GET /api/v1/groups/me` without touching the UI.
abstract class RoommateGroupRepository {
  Future<RoommateGroup?> myGroup();
  Future<RoommateGroup> attachListing(String listingId);
}
