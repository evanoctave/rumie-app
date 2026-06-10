// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swipe_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SwipeOut _$SwipeOutFromJson(Map<String, dynamic> json) => SwipeOut(
  matched: json['matched'] as bool,
  merge: json['merge'] as Map<String, dynamic>?,
  inquiry: json['inquiry'] as Map<String, dynamic>?,
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$SwipeOutToJson(SwipeOut instance) => <String, dynamic>{
  'matched': instance.matched,
  'merge': instance.merge,
  'inquiry': instance.inquiry,
  'reason': instance.reason,
};
