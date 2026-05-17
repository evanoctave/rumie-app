import 'package:json_annotation/json_annotation.dart';

import 'invite_status.dart';

part 'invite_out.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class InviteOut {
  final String id;
  final String groupId;
  final String inviteeId;
  final InviteStatus status;

  const InviteOut({
    required this.id,
    required this.groupId,
    required this.inviteeId,
    required this.status,
  });

  factory InviteOut.fromJson(Map<String, dynamic> json) =>
      _$InviteOutFromJson(json);
  Map<String, dynamic> toJson() => _$InviteOutToJson(this);
}
