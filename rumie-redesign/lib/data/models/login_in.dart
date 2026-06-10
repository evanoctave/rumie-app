import 'package:json_annotation/json_annotation.dart';

part 'login_in.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LoginIn {
  final String email;
  final String password;

  const LoginIn({required this.email, required this.password});

  factory LoginIn.fromJson(Map<String, dynamic> json) =>
      _$LoginInFromJson(json);
  Map<String, dynamic> toJson() => _$LoginInToJson(this);
}
