import '../../domain/entities/roommate_candidate.dart';
import '../../domain/entities/roommate_profile.dart';
import '../../domain/repositories/roommate_feed_repository.dart';
import '../../domain/services/compatibility_service.dart';
import 'mock_profiles.dart';

/// Serves the Discover feed from local mock data, ranked by the local
/// [CompatibilityService]. The short artificial delay keeps loading states
/// honest so swapping in the live API later doesn't surprise the UI.
class MockRoommateFeedRepository implements RoommateFeedRepository {
  MockRoommateFeedRepository({
    CompatibilityService? compatibility,
    RoommateProfile? currentUser,
    List<RoommateProfile>? roommates,
  }) : _compatibility = compatibility ?? const CompatibilityService(),
       _me = currentUser ?? mockCurrentUser,
       _roommates = roommates ?? mockRoommates;

  final CompatibilityService _compatibility;
  final RoommateProfile _me;
  final List<RoommateProfile> _roommates;
  final Set<String> _passed = {};
  final Set<String> _liked = {};

  @override
  Future<List<RoommateCandidate>> discover() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final candidates =
        _roommates
            .where((p) => !_passed.contains(p.id))
            .map(_toCandidate)
            .toList()
          ..sort(
            (a, b) => b.compatibilityScore.compareTo(a.compatibilityScore),
          );
    return candidates;
  }

  @override
  Future<RoommateCandidate?> byId(String id) async {
    for (final p in _roommates) {
      if (p.id == id) return _toCandidate(p);
    }
    return null;
  }

  @override
  Future<void> like(String id) async => _liked.add(id);

  @override
  Future<void> pass(String id) async => _passed.add(id);

  RoommateCandidate _toCandidate(RoommateProfile p) {
    final result = _compatibility.score(_me, p);
    return RoommateCandidate(
      profile: p,
      compatibilityScore: result.score,
      compatibilityReasons: result.reasons,
      distanceLabel: _distanceLabel(p),
      sharedInterests: _compatibility.sharedInterests(_me, p),
    );
  }

  String _distanceLabel(RoommateProfile p) {
    if (p.school == _me.school) return 'Same campus';
    return 'Near ${p.preferredNeighborhoods.isNotEmpty ? p.preferredNeighborhoods.first : p.school}';
  }
}
