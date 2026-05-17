import 'package:json_annotation/json_annotation.dart';

import 'asset_kind.dart';

part 'presign_in.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PresignIn {
  final AssetKind kind;
  final String contentType;

  const PresignIn({required this.kind, required this.contentType});

  factory PresignIn.fromJson(Map<String, dynamic> json) =>
      _$PresignInFromJson(json);
  Map<String, dynamic> toJson() => _$PresignInToJson(this);
}
