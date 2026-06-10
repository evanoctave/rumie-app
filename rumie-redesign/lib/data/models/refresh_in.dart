import 'package:json_annotation/json_annotation.dart';

part 'refresh_in.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RefreshIn {
  final String refresh;

  const RefreshIn({required this.refresh});

  factory RefreshIn.fromJson(Map<String, dynamic> json) =>
      _$RefreshInFromJson(json);
  Map<String, dynamic> toJson() => _$RefreshInToJson(this);
}
