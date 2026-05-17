// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MessageOut _$MessageOutFromJson(Map<String, dynamic> json) => MessageOut(
  id: json['id'] as String,
  conversationId: json['conversation_id'] as String,
  senderId: json['sender_id'] as String,
  body: json['body'] as String,
  ts: DateTime.parse(json['ts'] as String),
);

Map<String, dynamic> _$MessageOutToJson(MessageOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'conversation_id': instance.conversationId,
      'sender_id': instance.senderId,
      'body': instance.body,
      'ts': instance.ts.toIso8601String(),
    };
