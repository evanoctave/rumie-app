import 'package:json_annotation/json_annotation.dart';

part 'swipe_out.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class SwipeOut {
  final bool matched;

  /// Open object — server returns merge proposal on group-match path.
  final Map<String, dynamic>? merge;

  /// Open object — server returns inquiry payload on landlord-match path.
  final Map<String, dynamic>? inquiry;

  final String? reason;

  const SwipeOut({
    required this.matched,
    this.merge,
    this.inquiry,
    this.reason,
  });

  factory SwipeOut.fromJson(Map<String, dynamic> json) =>
      _$SwipeOutFromJson(json);
  Map<String, dynamic> toJson() => _$SwipeOutToJson(this);
}
