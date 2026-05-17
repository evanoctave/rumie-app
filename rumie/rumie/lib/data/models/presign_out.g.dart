// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'presign_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PresignOut _$PresignOutFromJson(Map<String, dynamic> json) => PresignOut(
  putUrl: json['put_url'] as String,
  assetUrl: json['asset_url'] as String,
  key: json['key'] as String,
  expiresAt: json['expires_at'] as String,
);

Map<String, dynamic> _$PresignOutToJson(PresignOut instance) =>
    <String, dynamic>{
      'put_url': instance.putUrl,
      'asset_url': instance.assetUrl,
      'key': instance.key,
      'expires_at': instance.expiresAt,
    };
