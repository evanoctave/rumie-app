import 'package:json_annotation/json_annotation.dart';

enum InquiryStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('accepted')
  accepted,
  @JsonValue('rejected')
  rejected,
}
