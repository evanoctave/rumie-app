import 'package:json_annotation/json_annotation.dart';

import 'preferences.dart';

part 'group_patch.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class GroupPatch {
  final Preferences? preferences;
  final int? capacity;

  const GroupPatch({this.preferences, this.capacity});

  factory GroupPatch.fromJson(Map<String, dynamic> json) =>
      _$GroupPatchFromJson(json);

  /// Strips unset (null) fields so PATCH does not overwrite server values.
  Map<String, dynamic> toJson() =>
      _$GroupPatchToJson(this)..removeWhere((_, v) => v == null);
}
