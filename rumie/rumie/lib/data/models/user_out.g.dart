// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserOut _$UserOutFromJson(Map<String, dynamic> json) => UserOut(
  id: json['id'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String?,
  role: $enumDecode(_$RoleEnumMap, json['role']),
  age: (json['age'] as num).toInt(),
  gender: $enumDecode(_$GenderEnumMap, json['gender']),
  profilePhotoUrl: json['profile_photo_url'] as String?,
);

Map<String, dynamic> _$UserOutToJson(UserOut instance) => <String, dynamic>{
  'id': instance.id,
  'email': instance.email,
  'phone': instance.phone,
  'role': _$RoleEnumMap[instance.role]!,
  'age': instance.age,
  'gender': _$GenderEnumMap[instance.gender]!,
  'profile_photo_url': instance.profilePhotoUrl,
};

const _$RoleEnumMap = {Role.rumie: 'rumie', Role.landlord: 'landlord'};

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.nonbinary: 'nonbinary',
  Gender.other: 'other',
};
