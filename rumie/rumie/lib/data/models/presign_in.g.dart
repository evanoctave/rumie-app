// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presign_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PresignIn _$PresignInFromJson(Map<String, dynamic> json) => PresignIn(
  kind: $enumDecode(_$AssetKindEnumMap, json['kind']),
  contentType: json['content_type'] as String,
);

Map<String, dynamic> _$PresignInToJson(PresignIn instance) => <String, dynamic>{
  'kind': _$AssetKindEnumMap[instance.kind]!,
  'content_type': instance.contentType,
};

const _$AssetKindEnumMap = {
  AssetKind.avatar: 'avatar',
  AssetKind.listingPhoto: 'listing_photo',
};
