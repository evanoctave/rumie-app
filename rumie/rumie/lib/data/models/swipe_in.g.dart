// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swipe_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwipeIn _$SwipeInFromJson(Map<String, dynamic> json) => SwipeIn(
  targetId: json['target_id'] as String,
  targetType: $enumDecode(_$SwipeTargetTypeEnumMap, json['target_type']),
  direction: $enumDecode(_$SwipeDirectionEnumMap, json['direction']),
);

Map<String, dynamic> _$SwipeInToJson(SwipeIn instance) => <String, dynamic>{
  'target_id': instance.targetId,
  'target_type': _$SwipeTargetTypeEnumMap[instance.targetType]!,
  'direction': _$SwipeDirectionEnumMap[instance.direction]!,
};

const _$SwipeTargetTypeEnumMap = {
  SwipeTargetType.group: 'group',
  SwipeTargetType.listing: 'listing',
};

const _$SwipeDirectionEnumMap = {
  SwipeDirection.left: 'left',
  SwipeDirection.right: 'right',
};
