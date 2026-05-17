// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'inquiry_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InquiryOut _$InquiryOutFromJson(Map<String, dynamic> json) => InquiryOut(
  id: json['id'] as String,
  groupId: json['group_id'] as String,
  listingId: json['listing_id'] as String,
  status: $enumDecode(_$InquiryStatusEnumMap, json['status']),
);

Map<String, dynamic> _$InquiryOutToJson(InquiryOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'group_id': instance.groupId,
      'listing_id': instance.listingId,
      'status': _$InquiryStatusEnumMap[instance.status]!,
    };

const _$InquiryStatusEnumMap = {
  InquiryStatus.pending: 'pending',
  InquiryStatus.accepted: 'accepted',
  InquiryStatus.rejected: 'rejected',
};
