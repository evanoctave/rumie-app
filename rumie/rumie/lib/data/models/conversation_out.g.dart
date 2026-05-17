// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conversation_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ConversationOut _$ConversationOutFromJson(Map<String, dynamic> json) =>
    ConversationOut(
      id: json['id'] as String,
      type: $enumDecode(_$ConversationTypeEnumMap, json['type']),
      participants:
          (json['participants'] as List<dynamic>)
              .map((e) => e as String)
              .toList(),
      groupId: json['group_id'] as String,
      listingId: json['listing_id'] as String?,
    );

Map<String, dynamic> _$ConversationOutToJson(ConversationOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': _$ConversationTypeEnumMap[instance.type]!,
      'participants': instance.participants,
      'group_id': instance.groupId,
      'listing_id': instance.listingId,
    };

const _$ConversationTypeEnumMap = {
  ConversationType.internalGroup: 'internal_group',
  ConversationType.landlordInquiry: 'landlord_inquiry',
};
