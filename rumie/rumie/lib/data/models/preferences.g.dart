// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Preferences _$PreferencesFromJson(Map<String, dynamic> json) => Preferences(
  budget: (json['budget'] as num?)?.toInt(),
  genderPref: json['gender_pref'] as String?,
  ageRange:
      (json['age_range'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList(),
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
);

Map<String, dynamic> _$PreferencesToJson(Preferences instance) =>
    <String, dynamic>{
      'budget': instance.budget,
      'gender_pref': instance.genderPref,
      'age_range': instance.ageRange,
      'tags': instance.tags,
    };
