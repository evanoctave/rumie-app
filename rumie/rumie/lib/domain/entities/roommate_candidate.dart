import '../../data/models/group_out.dart';
import '../../data/models/swipe_target_type.dart';

/// A swipeable discovery card. Replaces the legacy mock `Roommate` model.
///
/// The API exposes groups (not individual profiles) to discovery: a
/// `GroupOut` carries member ids, shared preferences and capacity, but no
/// names, photos or bios. The display fields below are derived from what the
/// server does send.
class RoommateCandidate {
  final String id;
  final SwipeTargetType targetType;

  /// "Solo rumie" or "Group of N".
  final String name;

  /// "22–26" from `preferences.age_range`; empty when unset.
  final String ageLabel;

  final int? budget;

  /// Open-spot summary, shown where the mock showed a neighborhood.
  final String location;

  final String bio;
  final List<String> tags;

  /// Optional artwork. The group API carries none, so this is normally null
  /// and presentation falls back to a generated avatar.
  final String? photoUrl;

  const RoommateCandidate({
    required this.id,
    required this.targetType,
    required this.name,
    required this.ageLabel,
    required this.budget,
    required this.location,
    required this.bio,
    required this.tags,
    this.photoUrl,
  });

  factory RoommateCandidate.fromGroup(GroupOut g) {
    final size = g.members.length;
    final prefs = g.preferences;
    final range = prefs.ageRange;
    final open = g.capacity - size;

    final gender = prefs.genderPref?.trim();
    final bio = StringBuffer(
      size <= 1 ? 'Looking for a roommate' : 'A group of $size looking for more roommates',
    );
    if (gender != null && gender.isNotEmpty) bio.write(' ($gender)');
    if (prefs.budget != null) bio.write(', budget around \$${prefs.budget}/mo');
    bio.write('.');

    return RoommateCandidate(
      id: g.id,
      targetType: SwipeTargetType.group,
      name: size <= 1 ? 'Solo rumie' : 'Group of $size',
      ageLabel: (range != null && range.length == 2) ? '${range[0]}–${range[1]}' : '',
      budget: prefs.budget,
      location: open > 0
          ? '$open open spot${open == 1 ? '' : 's'}'
          : 'Group of ${g.capacity}',
      bio: bio.toString(),
      tags: List.unmodifiable(prefs.tags),
    );
  }

  /// "Group of 3, 22–26" — falls back to just the name when no age range.
  String get headline => ageLabel.isEmpty ? name : '$name, $ageLabel';

  /// Used in "You and … liked each other."
  String get matchLabel => name == 'Solo rumie' ? 'this rumie' : 'this group';
}
