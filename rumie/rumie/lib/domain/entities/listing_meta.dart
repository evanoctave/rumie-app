import '../../data/models/listing_out.dart';

/// Listing attributes the UI shows that the API has no fields for
/// (type, beds/baths, availability).
///
/// Convention: listings posted from the app store them on the first line of
/// `description` as `"<type> · <beds> · Available <when>"`, followed by an
/// optional blank line and free text. Listings created elsewhere fall back to
/// a type inferred from the title and no beds/availability.
class ListingMeta {
  static const types = ['Room', 'Apartment', 'Condo', 'House', 'Duplex', 'Studio'];
  static const _sep = ' · ';
  static const _availPrefix = 'Available ';

  final String type;
  final String? bedsBaths;
  final String? availableDate;

  /// Description with the metadata line removed.
  final String body;

  const ListingMeta({
    required this.type,
    this.bedsBaths,
    this.availableDate,
    this.body = '',
  });

  factory ListingMeta.of(ListingOut l) => parse(l.title, l.description);

  static ListingMeta parse(String title, String description) {
    final lines = description.split('\n');
    final parts = lines.first.split(_sep);
    if (parts.length == 3 &&
        types.contains(parts[0]) &&
        parts[2].startsWith(_availPrefix)) {
      return ListingMeta(
        type: parts[0],
        bedsBaths: parts[1],
        availableDate: parts[2].substring(_availPrefix.length),
        body: lines.skip(1).join('\n').trim(),
      );
    }
    return ListingMeta(type: _inferType(title, description), body: description);
  }

  /// Builds the `description` to send in `ListingCreate`.
  static String encode({
    required String type,
    required String bedsBaths,
    required String availableDate,
    String body = '',
  }) {
    final head = '$type$_sep$bedsBaths$_sep$_availPrefix$availableDate';
    return body.trim().isEmpty ? head : '$head\n\n${body.trim()}';
  }

  static String _inferType(String title, String description) {
    final hay = '$title $description'.toLowerCase();
    for (final t in types) {
      if (hay.contains(t.toLowerCase())) return t;
    }
    return 'Listing';
  }
}
