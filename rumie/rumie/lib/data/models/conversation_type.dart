import 'package:json_annotation/json_annotation.dart';

enum ConversationType {
  @JsonValue('internal_group')
  internalGroup,
  @JsonValue('landlord_inquiry')
  landlordInquiry,
}
