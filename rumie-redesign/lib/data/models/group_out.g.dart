// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupOut _$GroupOutFromJson(Map<String, dynamic> json) => GroupOut(
  id: json['id'] as String,
  adminId: json['admin_id'] as String,
  members: (json['members'] as List<dynamic>).map((e) => e as String).toList(),
  preferences: Preferences.fromJson(
    json['preferences'] as Map<String, dynamic>,
  ),
  capacity: (json['capacity'] as num).toInt(),
);

Map<String, dynamic> _$GroupOutToJson(GroupOut instance) => <String, dynamic>{
  'id': instance.id,
  'admin_id': instance.adminId,
  'members': instance.members,
  'preferences': instance.preferences.toJson(),
  'capacity': instance.capacity,
};
