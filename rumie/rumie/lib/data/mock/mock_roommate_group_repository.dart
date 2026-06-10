import '../../domain/entities/roommate_group.dart';
import '../../domain/repositories/roommate_group_repository.dart';
import 'mock_profiles.dart';

/// Serves a single sample group so the Groups surface has a real shape to
/// render. Swaps to `/api/v1/groups/*` later.
class MockRoommateGroupRepository implements RoommateGroupRepository {
  RoommateGroup _group = RoommateGroup(
    id: 'grp-1',
    name: 'Fall move-in crew',
    members: [
      mockCurrentUser,
      mockRoommates.firstWhere((p) => p.id == 'rm-jordan'),
      mockRoommates.firstWhere((p) => p.id == 'rm-priya'),
    ],
    sharedBudgetMin: 850,
    sharedBudgetMax: 1300,
    preferredNeighborhoods: const ['Westwood', 'Palms'],
    compatibilitySummary:
        'High fit: overlapping budgets, all aiming for a fall move-in near campus, and everyone keeps things tidy.',
    groupChatId: 'conv-grp-1',
  );

  @override
  Future<RoommateGroup?> myGroup() async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _group;
  }

  @override
  Future<RoommateGroup> attachListing(String listingId) async {
    _group = RoommateGroup(
      id: _group.id,
      name: _group.name,
      members: _group.members,
      sharedBudgetMin: _group.sharedBudgetMin,
      sharedBudgetMax: _group.sharedBudgetMax,
      preferredNeighborhoods: _group.preferredNeighborhoods,
      preferredListingId: listingId,
      compatibilitySummary: _group.compatibilitySummary,
      groupChatId: _group.groupChatId,
    );
    return _group;
  }
}
