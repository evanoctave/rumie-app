// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_create.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingCreate _$ListingCreateFromJson(Map<String, dynamic> json) =>
    ListingCreate(
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      rent: (json['rent'] as num).toInt(),
      location: json['location'] as String,
      photoUrls:
          (json['photo_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$ListingCreateToJson(ListingCreate instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'rent': instance.rent,
      'location': instance.location,
      'photo_urls': instance.photoUrls,
    };
