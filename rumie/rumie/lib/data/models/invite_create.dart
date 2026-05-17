import 'package:json_annotation/json_annotation.dart';

part 'invite_create.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class InviteCreate {
  final String? inviteeEmail;
  final String? inviteeId;

  const InviteCreate({this.inviteeEmail, this.inviteeId});

  factory InviteCreate.fromJson(Map<String, dynamic> json) =>
      _$InviteCreateFromJson(json);
  Map<String, dynamic> toJson() => _$InviteCreateToJson(this);
}
