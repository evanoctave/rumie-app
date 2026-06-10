import 'package:json_annotation/json_annotation.dart';

import 'gender.dart';
import 'role.dart';

part 'register_in.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class RegisterIn {
  final String email;
  final String password;
  final Role role;
  final int age;
  final Gender gender;
  final String? phone;
  final int capacity;

  const RegisterIn({
    required this.email,
    required this.password,
    required this.role,
    required this.age,
    required this.gender,
    this.phone,
    this.capacity = 1,
  });

  factory RegisterIn.fromJson(Map<String, dynamic> json) =>
      _$RegisterInFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterInToJson(this);
}
