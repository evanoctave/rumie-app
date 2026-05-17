import 'package:json_annotation/json_annotation.dart';

enum InviteStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('rejected')
  rejected,
}
