import 'package:json_annotation/json_annotation.dart';

import 'conversation_type.dart';

part 'conversation_out.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ConversationOut {
  final String id;
  final ConversationType type;
  final List<String> participants;
  final String groupId;
  final String? listingId;

  const ConversationOut({
    required this.id,
    required this.type,
    required this.participants,
    required this.groupId,
    required this.listingId,
  });

  factory ConversationOut.fromJson(Map<String, dynamic> json) =>
      _$ConversationOutFromJson(json);
  Map<String, dynamic> toJson() => _$ConversationOutToJson(this);
}
