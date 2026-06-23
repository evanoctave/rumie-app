import 'package:json_annotation/json_annotation.dart';

import 'gender.dart';
import 'role.dart';

part 'user_out.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class UserOut {
  final String id;
  final String email;
  final String? phone;
  final Role role;
  final int age;
  final Gender gender;
  final String? profilePhotoUrl;

  const UserOut({
    required this.id,
    required this.email,
    required this.phone,
    required this.role,
    required this.age,
    required this.gender,
    required this.profilePhotoUrl,
  });

  factory UserOut.fromJson(Map<String, dynamic> json) =>
      _$UserOutFromJson(json);
  Map<String, dynamic> toJson() => _$UserOutToJson(this);
}
