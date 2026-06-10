import '../entities/roommate_candidate.dart';

/// Discover-feed data source.
///
/// Mock-backed today (`MockRoommateFeedRepository`); swaps to
/// `GET /api/v1/roommates/discover` without touching the UI.
abstract class RoommateFeedRepository {
  Future<List<RoommateCandidate>> discover();
  Future<RoommateCandidate?> byId(String id);
  Future<void> like(String id);
  Future<void> pass(String id);
}
