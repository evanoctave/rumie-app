import 'package:json_annotation/json_annotation.dart';

part 'listing_patch.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class ListingPatch {
  final String? title;
  final String? description;
  final int? rent;
  final String? location;
  final List<String>? photoUrls;

  const ListingPatch({
    this.title,
    this.description,
    this.rent,
    this.location,
    this.photoUrls,
  });

  factory ListingPatch.fromJson(Map<String, dynamic> json) =>
      _$ListingPatchFromJson(json);

  /// Strips unset (null) fields so PATCH does not overwrite server values.
  Map<String, dynamic> toJson() =>
      _$ListingPatchToJson(this)..removeWhere((_, v) => v == null);
}
