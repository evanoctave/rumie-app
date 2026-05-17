import 'package:json_annotation/json_annotation.dart';

import 'preferences.dart';

part 'group_out.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class GroupOut {
  final String id;
  final String adminId;
  final List<String> members;
  final Preferences preferences;
  final int capacity;

  const GroupOut({
    required this.id,
    required this.adminId,
    required this.members,
    required this.preferences,
    required this.capacity,
  });

  factory GroupOut.fromJson(Map<String, dynamic> json) =>
      _$GroupOutFromJson(json);
  Map<String, dynamic> toJson() => _$GroupOutToJson(this);
}
