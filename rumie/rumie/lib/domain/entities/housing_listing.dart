/// A housing listing in the Housing tab. Pure Dart entity.
class HousingListing {
  final String id;
  final String title;
  final String description;

  /// Coarse label only ("Near Westwood Village") — exact addresses are not
  /// shown until users connect, by design (safety).
  final String addressLabel;
  final String neighborhood;
  final String city;
  final String state;
  final String type;
  final double distanceFromCampusMiles;
  final int priceMonthly;
  final int bedrooms;
  final double bathrooms;
  final int availableRooms;
  final int sqft;
  final int leaseLengthMonths;
  final String moveInLabel;
  final bool furnished;
  final String petPolicy;
  final List<String> amenities;
  final List<String> imageAssets;
  final bool verified;
  final String landlordOrSource;
  final List<String> safetyNotes;
  final String nearbyCampus;
  final double? latitude;
  final double? longitude;

  const HousingListing({
    required this.id,
    required this.title,
    this.description = '',
    required this.addressLabel,
    required this.neighborhood,
    required this.city,
    this.state = 'CA',
    required this.type,
    required this.distanceFromCampusMiles,
    required this.priceMonthly,
    required this.bedrooms,
    required this.bathrooms,
    this.availableRooms = 1,
    this.sqft = 0,
    this.leaseLengthMonths = 12,
    this.moveInLabel = 'Now',
    this.furnished = false,
    this.petPolicy = 'No pets',
    this.amenities = const [],
    this.imageAssets = const [],
    this.verified = false,
    this.landlordOrSource = 'Listed by owner',
    this.safetyNotes = const [],
    this.nearbyCampus = '',
    this.latitude,
    this.longitude,
  });

  String get bedsBathsLabel {
    final beds = bedrooms == 0 ? 'Studio' : '$bedrooms bd';
    final baths =
        bathrooms == bathrooms.truncate()
            ? '${bathrooms.toInt()} ba'
            : '$bathrooms ba';
    return '$beds · $baths';
  }

  String get distanceLabel {
    if (distanceFromCampusMiles < 1) {
      return '${(distanceFromCampusMiles * 10).round() / 10} mi to campus';
    }
    return '${distanceFromCampusMiles.toStringAsFixed(1)} mi to campus';
  }
}
