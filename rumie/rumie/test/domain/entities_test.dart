import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/domain/entities/entities.dart';
import 'package:roomie/domain/errors/api_exception.dart';
import 'package:roomie/domain/errors/error_messages.dart';

GroupOut _group({
  List<String> members = const ['u1'],
  int capacity = 3,
  Preferences preferences = const Preferences(),
}) =>
    GroupOut(
      id: 'g1',
      adminId: 'u1',
      members: members,
      preferences: preferences,
      capacity: capacity,
    );

void main() {
  group('RoommateCandidate.fromGroup', () {
    test('solo group with full preferences', () {
      final c = RoommateCandidate.fromGroup(_group(
        preferences: const Preferences(
          budget: 1200,
          genderPref: 'any',
          ageRange: [22, 26],
          tags: ['Night owl', 'Gamer'],
        ),
      ));
      expect(c.id, 'g1');
      expect(c.targetType, SwipeTargetType.group);
      expect(c.headline, 'Solo rumie, 22–26');
      expect(c.budget, 1200);
      expect(c.location, '2 open spots');
      expect(c.tags, ['Night owl', 'Gamer']);
      expect(c.bio, contains('\$1200/mo'));
      expect(c.matchLabel, 'this rumie');
    });

    test('sparse group falls back gracefully', () {
      final c = RoommateCandidate.fromGroup(
        _group(members: const ['a', 'b', 'c'], capacity: 3),
      );
      expect(c.headline, 'Group of 3');
      expect(c.budget, isNull);
      expect(c.location, 'Group of 3');
      expect(c.tags, isEmpty);
      expect(c.matchLabel, 'this group');
    });
  });

  group('ListingMeta', () {
    test('encode → parse round-trips app-posted metadata', () {
      final desc = ListingMeta.encode(
        type: 'Condo',
        bedsBaths: '2 bed / 2 bath',
        availableDate: 'July 1',
        body: 'Quiet street.',
      );
      final m = ListingMeta.parse('Nice place', desc);
      expect(m.type, 'Condo');
      expect(m.bedsBaths, '2 bed / 2 bath');
      expect(m.availableDate, 'July 1');
      expect(m.body, 'Quiet street.');
    });

    test('foreign descriptions infer type from the title, no beds/avail', () {
      final m = ListingMeta.parse('Sunny studio downtown', 'Great light.');
      expect(m.type, 'Studio');
      expect(m.bedsBaths, isNull);
      expect(m.availableDate, isNull);
      expect(m.body, 'Great light.');
    });

    test('unknown type → "Listing"', () {
      expect(ListingMeta.parse('Loft', '').type, 'Listing');
    });
  });

  group('MatchSummary', () {
    const conv = ConversationOut(
      id: 'c1',
      type: ConversationType.landlordInquiry,
      participants: ['u1', 'u2'],
      groupId: 'g1',
      listingId: 'l1',
    );

    test('listing inquiry is titled by its listing', () {
      final m = MatchSummary.fromConversation(
        conv,
        listing: const ListingOut(
          id: 'l1',
          landlordId: 'u2',
          title: 'Bright room',
          description: '',
          rent: 1250,
          location: 'Westwood',
          photoUrls: [],
        ),
      );
      expect(m.title, 'Bright room');
      expect(m.subtitle, 'Westwood · \$1250/mo');
    });

    test('falls back when the listing is unavailable', () {
      expect(MatchSummary.fromConversation(conv).title, 'Listing inquiry');
    });

    test('group chat', () {
      final m = MatchSummary.fromConversation(const ConversationOut(
        id: 'c2',
        type: ConversationType.internalGroup,
        participants: ['u1', 'u2', 'u3'],
        groupId: 'g1',
        listingId: null,
      ));
      expect(m.title, 'Group chat');
      expect(m.subtitle, contains('2 people'));
    });
  });

  group('error_messages (V5, V6)', () {
    test('typed errors pass their safe message; others get the fallback', () {
      expect(userMessage(const NetworkException('offline')), 'offline');
      expect(userMessage(StateError('boom'), fallback: 'x'), 'x');
    });

    test('field errors only for ValidationException', () {
      const v = ValidationException({
        'email': ['bad'],
      });
      expect(firstFieldError(fieldErrorsOf(v), 'email'), 'bad');
      expect(firstFieldError(fieldErrorsOf(v), 'password'), isNull);
      expect(fieldErrorsOf(const ServerException('x')), isEmpty);
    });
  });
}
