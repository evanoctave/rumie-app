import 'roommate_profile.dart';

/// A group of roommates searching for housing together.
class RoommateGroup {
  final String id;
  final String name;
  final List<RoommateProfile> members;
  final int sharedBudgetMin;
  final int sharedBudgetMax;
  final List<String> preferredNeighborhoods;

  /// Listing the group is rallying around, if any.
  final String? preferredListingId;
  final String compatibilitySummary;
  final String? groupChatId;

  const RoommateGroup({
    required this.id,
    required this.name,
    required this.members,
    required this.sharedBudgetMin,
    required this.sharedBudgetMax,
    this.preferredNeighborhoods = const [],
    this.preferredListingId,
    this.compatibilitySummary = '',
    this.groupChatId,
  });

  String get budgetLabel => '\$$sharedBudgetMin–\$$sharedBudgetMax/mo each';
}
