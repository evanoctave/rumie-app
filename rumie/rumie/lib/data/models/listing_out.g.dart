// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'listing_out.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ListingOut _$ListingOutFromJson(Map<String, dynamic> json) => ListingOut(
  id: json['id'] as String,
  landlordId: json['landlord_id'] as String,
  title: json['title'] as String,
  description: json['description'] as String,
  rent: (json['rent'] as num).toInt(),
  location: json['location'] as String,
  photoUrls:
      (json['photo_urls'] as List<dynamic>).map((e) => e as String).toList(),
);

Map<String, dynamic> _$ListingOutToJson(ListingOut instance) =>
    <String, dynamic>{
      'id': instance.id,
      'landlord_id': instance.landlordId,
      'title': instance.title,
      'description': instance.description,
      'rent': instance.rent,
      'location': instance.location,
      'photo_urls': instance.photoUrls,
    };
