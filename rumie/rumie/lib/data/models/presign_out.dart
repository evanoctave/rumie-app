import 'package:json_annotation/json_annotation.dart';

part 'presign_out.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class PresignOut {
  final String putUrl;
  final String assetUrl;
  final String key;

  /// OpenAPI declares `type: string` (no `format`) — server returns an ISO
  /// timestamp string but it isn't typed as date-time, so we keep it raw.
  final String expiresAt;

  const PresignOut({
    required this.putUrl,
    required this.assetUrl,
    required this.key,
    required this.expiresAt,
  });

  factory PresignOut.fromJson(Map<String, dynamic> json) =>
      _$PresignOutFromJson(json);
  Map<String, dynamic> toJson() => _$PresignOutToJson(this);
}
