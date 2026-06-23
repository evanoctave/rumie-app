import 'package:json_annotation/json_annotation.dart';

enum Role {
  @JsonValue('rumie')
  rumie,
  @JsonValue('landlord')
  landlord,
}
