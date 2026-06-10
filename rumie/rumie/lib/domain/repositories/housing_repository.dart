import '../entities/housing_listing.dart';

/// Housing-browse data source.
///
/// Mock-backed today (`MockHousingRepository`); swaps to
/// `GET /api/v1/housing/listings` without touching the UI.
abstract class HousingRepository {
  Future<List<HousingListing>> browse();
  Future<HousingListing?> byId(String id);
}
