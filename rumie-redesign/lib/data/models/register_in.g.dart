// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_in.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterIn _$RegisterInFromJson(Map<String, dynamic> json) => RegisterIn(
  email: json['email'] as String,
  password: json['password'] as String,
  role: $enumDecode(_$RoleEnumMap, json['role']),
  age: (json['age'] as num).toInt(),
  gender: $enumDecode(_$GenderEnumMap, json['gender']),
  phone: json['phone'] as String?,
  capacity: (json['capacity'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$RegisterInToJson(RegisterIn instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
      'role': _$RoleEnumMap[instance.role]!,
      'age': instance.age,
      'gender': _$GenderEnumMap[instance.gender]!,
      'phone': instance.phone,
      'capacity': instance.capacity,
    };

const _$RoleEnumMap = {Role.rumie: 'rumie', Role.landlord: 'landlord'};

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.nonbinary: 'nonbinary',
  Gender.other: 'other',
};
