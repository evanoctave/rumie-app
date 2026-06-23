import 'package:json_annotation/json_annotation.dart';

part 'message_in.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class MessageIn {
  final String body;

  const MessageIn({required this.body});

  factory MessageIn.fromJson(Map<String, dynamic> json) =>
      _$MessageInFromJson(json);
  Map<String, dynamic> toJson() => _$MessageInToJson(this);
}
