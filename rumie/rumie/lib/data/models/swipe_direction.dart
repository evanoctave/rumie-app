import 'package:json_annotation/json_annotation.dart';

enum SwipeDirection {
  @JsonValue('left')
  left,
  @JsonValue('right')
  right,
}
