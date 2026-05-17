import '../../data/models/listing_create.dart';
import '../../data/models/listing_out.dart';
import '../../data/models/listing_patch.dart';

abstract class ListingsRepository {
  Future<ListingOut> create(ListingCreate body);
  Future<ListingOut> get(String listingId);
  Future<ListingOut> patch(String listingId, ListingPatch body);
  Future<void> delete(String listingId);
}
