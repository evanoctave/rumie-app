import 'roommate_profile.dart';

/// A roommate surfaced in the Discover feed: a profile plus everything the
/// matching layer computed about how well they fit the current user.
class RoommateCandidate {
  final RoommateProfile profile;

  /// 0–100. Produced by `CompatibilityService` locally for now; a backend
  /// ranking service can replace it without touching the UI.
  final int compatibilityScore;

  /// Short, human-readable "why you match" lines.
  final List<String> compatibilityReasons;

  final String distanceLabel;
  final List<String> sharedInterests;

  const RoommateCandidate({
    required this.profile,
    required this.compatibilityScore,
    this.compatibilityReasons = const [],
    this.distanceLabel = '',
    this.sharedInterests = const [],
  });
}
