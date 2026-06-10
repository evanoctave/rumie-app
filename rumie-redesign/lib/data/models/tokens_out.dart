import 'package:json_annotation/json_annotation.dart';

part 'tokens_out.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class TokensOut {
  final String access;
  final String refresh;

  const TokensOut({required this.access, required this.refresh});

  factory TokensOut.fromJson(Map<String, dynamic> json) =>
      _$TokensOutFromJson(json);
  Map<String, dynamic> toJson() => _$TokensOutToJson(this);
}
