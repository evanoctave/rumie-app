import 'package:json_annotation/json_annotation.dart';

part 'preferences.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Preferences {
  final int? budget;
  final String? genderPref;

  /// OpenAPI declares prefixItems [int, int] — server returns [min, max].
  /// Modelled as `List<int>?`; callers should treat as a 2-tuple.
  final List<int>? ageRange;

  final List<String> tags;

  const Preferences({
    this.budget,
    this.genderPref,
    this.ageRange,
    this.tags = const [],
  });

  factory Preferences.fromJson(Map<String, dynamic> json) =>
      _$PreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$PreferencesToJson(this);
}
