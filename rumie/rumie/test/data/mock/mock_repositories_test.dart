import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/data/mock/mock_housing_repository.dart';
import 'package:roomie/data/mock/mock_roommate_feed_repository.dart';
import 'package:roomie/data/mock/mock_roommate_group_repository.dart';

void main() {
  group('MockRoommateFeedRepository', () {
    test('discover returns candidates ranked by score', () async {
      final repo = MockRoommateFeedRepository();
      final candidates = await repo.discover();

      expect(candidates, isNotEmpty);
      for (var i = 1; i < candidates.length; i++) {
        expect(
          candidates[i - 1].compatibilityScore,
          greaterThanOrEqualTo(candidates[i].compatibilityScore),
        );
      }
    });

    test(
      'passed candidates disappear from subsequent discover calls',
      () async {
        final repo = MockRoommateFeedRepository();
        final first = (await repo.discover()).first;
        await repo.pass(first.profile.id);

        final after = await repo.discover();
        expect(
          after.map((c) => c.profile.id),
          isNot(contains(first.profile.id)),
        );
      },
    );

    test('byId resolves a known profile', () async {
      final repo = MockRoommateFeedRepository();
      final candidate = await repo.byId('rm-marcus');
      expect(candidate, isNotNull);
      expect(candidate!.profile.name, 'Marcus');
      expect(candidate.compatibilityScore, inInclusiveRange(0, 100));
    });
  });

  group('MockHousingRepository', () {
    test('browse returns listings and byId round-trips', () async {
      final repo = MockHousingRepository();
      final listings = await repo.browse();
      expect(listings, isNotEmpty);

      final found = await repo.byId(listings.first.id);
      expect(found, isNotNull);
      expect(found!.title, listings.first.title);
    });

    test('byId returns null for unknown ids', () async {
      final repo = MockHousingRepository();
      expect(await repo.byId('nope'), isNull);
    });
  });

  group('MockRoommateGroupRepository', () {
    test('attachListing sets the preferred listing', () async {
      final repo = MockRoommateGroupRepository();
      final before = await repo.myGroup();
      expect(before!.preferredListingId, isNull);

      final after = await repo.attachListing('ls-gayley');
      expect(after.preferredListingId, 'ls-gayley');
      expect(after.members, before.members);
    });
  });
}
