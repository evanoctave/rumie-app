import 'package:json_annotation/json_annotation.dart';

part 'listing_create.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ListingCreate {
  final String title;
  final String description;
  final int rent;
  final String location;
  final List<String> photoUrls;

  const ListingCreate({
    required this.title,
    this.description = '',
    required this.rent,
    required this.location,
    this.photoUrls = const [],
  });

  factory ListingCreate.fromJson(Map<String, dynamic> json) =>
      _$ListingCreateFromJson(json);
  Map<String, dynamic> toJson() => _$ListingCreateToJson(this);
}
