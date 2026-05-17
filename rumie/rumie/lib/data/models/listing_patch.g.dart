// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_patch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingPatch _$ListingPatchFromJson(Map<String, dynamic> json) => ListingPatch(
  title: json['title'] as String?,
  description: json['description'] as String?,
  rent: (json['rent'] as num?)?.toInt(),
  location: json['location'] as String?,
  photoUrls:
      (json['photo_urls'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$ListingPatchToJson(ListingPatch instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'rent': instance.rent,
      'location': instance.location,
      'photo_urls': instance.photoUrls,
    };
