import 'package:json_annotation/json_annotation.dart';

import 'validation_error.dart';

part 'http_validation_error.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class HTTPValidationError {
  final List<ValidationError>? detail;

  const HTTPValidationError({this.detail});

  factory HTTPValidationError.fromJson(Map<String, dynamic> json) =>
      _$HTTPValidationErrorFromJson(json);
  Map<String, dynamic> toJson() => _$HTTPValidationErrorToJson(this);
}
