import 'package:json_annotation/json_annotation.dart';

import 'swipe_direction.dart';
import 'swipe_target_type.dart';

part 'swipe_in.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SwipeIn {
  final String targetId;
  final SwipeTargetType targetType;
  final SwipeDirection direction;

  const SwipeIn({
    required this.targetId,
    required this.targetType,
    required this.direction,
  });

  factory SwipeIn.fromJson(Map<String, dynamic> json) =>
      _$SwipeInFromJson(json);
  Map<String, dynamic> toJson() => _$SwipeInToJson(this);
}
