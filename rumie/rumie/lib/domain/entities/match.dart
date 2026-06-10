import 'roommate_profile.dart';

/// A mutual match between the current user and another roommate.
class RoommateMatch {
  final String id;
  final RoommateProfile profile;
  final DateTime matchedAt;
  final String lastMessagePreview;
  final int unreadCount;
  final int compatibilityScore;

  const RoommateMatch({
    required this.id,
    required this.profile,
    required this.matchedAt,
    this.lastMessagePreview = '',
    this.unreadCount = 0,
    required this.compatibilityScore,
  });

  RoommateMatch copyWith({String? lastMessagePreview, int? unreadCount}) {
    return RoommateMatch(
      id: id,
      profile: profile,
      matchedAt: matchedAt,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      unreadCount: unreadCount ?? this.unreadCount,
      compatibilityScore: compatibilityScore,
    );
  }
}
