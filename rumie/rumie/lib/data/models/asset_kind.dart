import 'package:json_annotation/json_annotation.dart';

enum AssetKind {
  @JsonValue('avatar')
  avatar,
  @JsonValue('listing_photo')
  listingPhoto,
}
