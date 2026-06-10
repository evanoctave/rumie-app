import 'package:json_annotation/json_annotation.dart';

import 'tokens_out.dart';
import 'user_out.dart';

part 'register_out.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class RegisterOut {
  final UserOut user;
  final TokensOut tokens;

  const RegisterOut({required this.user, required this.tokens});

  factory RegisterOut.fromJson(Map<String, dynamic> json) =>
      _$RegisterOutFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterOutToJson(this);
}
