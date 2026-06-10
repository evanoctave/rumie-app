import 'package:json_annotation/json_annotation.dart';

enum SwipeTargetType {
  @JsonValue('group')
  group,
  @JsonValue('listing')
  listing,
}
