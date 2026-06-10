// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_patch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupPatch _$GroupPatchFromJson(Map<String, dynamic> json) => GroupPatch(
  preferences:
      json['preferences'] == null
          ? null
          : Preferences.fromJson(json['preferences'] as Map<String, dynamic>),
  capacity: (json['capacity'] as num?)?.toInt(),
);

Map<String, dynamic> _$GroupPatchToJson(GroupPatch instance) =>
    <String, dynamic>{
      'preferences': instance.preferences?.toJson(),
      'capacity': instance.capacity,
    };
