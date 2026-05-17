import 'package:json_annotation/json_annotation.dart';

part 'listing_out.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ListingOut {
  final String id;
  final String landlordId;
  final String title;
  final String description;
  final int rent;
  final String location;
  final List<String> photoUrls;

  const ListingOut({
    required this.id,
    required this.landlordId,
    required this.title,
    required this.description,
    required this.rent,
    required this.location,
    required this.photoUrls,
  });

  factory ListingOut.fromJson(Map<String, dynamic> json) =>
      _$ListingOutFromJson(json);
  Map<String, dynamic> toJson() => _$ListingOutToJson(this);
}
