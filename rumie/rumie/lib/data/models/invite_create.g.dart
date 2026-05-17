// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invite_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InviteCreate _$InviteCreateFromJson(Map<String, dynamic> json) => InviteCreate(
  inviteeEmail: json['invitee_email'] as String?,
  inviteeId: json['invitee_id'] as String?,
);

Map<String, dynamic> _$InviteCreateToJson(InviteCreate instance) =>
    <String, dynamic>{
      'invitee_email': instance.inviteeEmail,
      'invitee_id': instance.inviteeId,
    };
