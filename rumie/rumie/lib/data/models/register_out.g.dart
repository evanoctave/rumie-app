// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterOut _$RegisterOutFromJson(Map<String, dynamic> json) => RegisterOut(
  user: UserOut.fromJson(json['user'] as Map<String, dynamic>),
  tokens: TokensOut.fromJson(json['tokens'] as Map<String, dynamic>),
);

Map<String, dynamic> _$RegisterOutToJson(RegisterOut instance) =>
    <String, dynamic>{
      'user': instance.user.toJson(),
      'tokens': instance.tokens.toJson(),
    };
