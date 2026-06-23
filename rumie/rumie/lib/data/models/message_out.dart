import 'package:json_annotation/json_annotation.dart';

part 'message_out.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MessageOut {
  final String id;
  final String conversationId;
  final String senderId;
  final String body;
  final DateTime ts;

  const MessageOut({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
    required this.ts,
  });

  factory MessageOut.fromJson(Map<String, dynamic> json) =>
      _$MessageOutFromJson(json);
  Map<String, dynamic> toJson() => _$MessageOutToJson(this);
}
