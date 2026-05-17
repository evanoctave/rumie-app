import 'package:json_annotation/json_annotation.dart';

import 'inquiry_status.dart';

part 'inquiry_out.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class InquiryOut {
  final String id;
  final String groupId;
  final String listingId;
  final InquiryStatus status;

  const InquiryOut({
    required this.id,
    required this.groupId,
    required this.listingId,
    required this.status,
  });

  factory InquiryOut.fromJson(Map<String, dynamic> json) =>
      _$InquiryOutFromJson(json);
  Map<String, dynamic> toJson() => _$InquiryOutToJson(this);
}
