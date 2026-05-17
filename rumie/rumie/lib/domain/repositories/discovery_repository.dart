import '../../data/models/group_out.dart';
import '../../data/models/listing_out.dart';

abstract class DiscoveryRepository {
  Future<List<GroupOut>> discoverGroups({int limit = 20});
  Future<List<ListingOut>> discoverListings({int limit = 20});
}
