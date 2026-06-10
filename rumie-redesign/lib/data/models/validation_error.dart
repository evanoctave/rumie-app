import 'package:json_annotation/json_annotation.dart';

part 'validation_error.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ValidationError {
  /// Heterogeneous list of `String` and `int` per FastAPI loc tuples.
  final List<dynamic> loc;
  final String msg;
  final String type;
  final dynamic input;
  final Map<String, dynamic>? ctx;

  const ValidationError({
    required this.loc,
    required this.msg,
    required this.type,
    this.input,
    this.ctx,
  });

  factory ValidationError.fromJson(Map<String, dynamic> json) =>
      _$ValidationErrorFromJson(json);
  Map<String, dynamic> toJson() => _$ValidationErrorToJson(this);
}
