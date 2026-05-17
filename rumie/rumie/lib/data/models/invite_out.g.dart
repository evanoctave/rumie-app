// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InviteOut _$InviteOutFromJson(Map<String, dynamic> json) => InviteOut(
  id: json['id'] as String,
  groupId: json['group_id'] as String,
  inviteeId: json['invitee_id'] as String,
  status: $enumDecode(_$InviteStatusEnumMap, json['status']),
);

Map<String, dynamic> _$InviteOutToJson(InviteOut instance) => <String, dynamic>{
  'id': instance.id,
  'group_id': instance.groupId,
  'invitee_id': instance.inviteeId,
  'status': _$InviteStatusEnumMap[instance.status]!,
};

const _$InviteStatusEnumMap = {
  InviteStatus.pending: 'pending',
  InviteStatus.accepted: 'accepted',
  InviteStatus.rejected: 'rejected',
};
