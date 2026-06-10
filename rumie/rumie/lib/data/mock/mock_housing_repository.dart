import '../../domain/entities/housing_listing.dart';
import '../../domain/repositories/housing_repository.dart';
import 'mock_listings.dart';

/// Serves the Housing tab from local mock data.
class MockHousingRepository implements HousingRepository {
  MockHousingRepository({List<HousingListing>? listings})
    : _listings = listings ?? mockListings;

  final List<HousingListing> _listings;

  @override
  Future<List<HousingListing>> browse() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List.unmodifiable(_listings);
  }

  @override
  Future<HousingListing?> byId(String id) async {
    for (final l in _listings) {
      if (l.id == id) return l;
    }
    return null;
  }
}
