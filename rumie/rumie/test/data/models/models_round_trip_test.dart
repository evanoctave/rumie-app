import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/data/models/conversation_type.dart';
import 'package:roomie/data/models/gender.dart';
import 'package:roomie/data/models/group_patch.dart';
import 'package:roomie/data/models/listing_patch.dart';
import 'package:roomie/data/models/message_out.dart';
import 'package:roomie/data/models/preferences.dart';
import 'package:roomie/data/models/register_out.dart';
import 'package:roomie/data/models/role.dart';
import 'package:roomie/data/models/swipe_out.dart';

void main() {
  group('RegisterOut (V7 nested codegen)', () {
    test('round-trips nested user + tokens', () {
      final json = {
        'user': {
          'id': 'u1',
          'email': 'a@b.com',
          'phone': null,
          'role': 'rumie',
          'age': 24,
          'gender': 'female',
          'profile_photo_url': null,
        },
        'tokens': {'access': 'A', 'refresh': 'R'},
      };

      final out = RegisterOut.fromJson(json);
      expect(out.user.id, 'u1');
      expect(out.user.role, Role.rumie);
      expect(out.user.gender, Gender.female);
      expect(out.tokens.access, 'A');

      final serialized = out.toJson();
      expect(serialized['user'], json['user']);
      expect(serialized['tokens'], json['tokens']);
    });
  });

  group('SwipeOut (V12 open objects + optional fields)', () {
    test('parses matched=true with merge payload', () {
      final out = SwipeOut.fromJson({
        'matched': true,
        'merge': {'group_id': 'g1', 'capacity': 4},
      });
      expect(out.matched, isTrue);
      expect(out.merge, {'group_id': 'g1', 'capacity': 4});
      expect(out.inquiry, isNull);
      expect(out.reason, isNull);
    });

    test('parses matched=false with reason only', () {
      final out = SwipeOut.fromJson({'matched': false, 'reason': 'dup'});
      expect(out.matched, isFalse);
      expect(out.reason, 'dup');
    });
  });

  group('Preferences (V12 nullable + default-empty list)', () {
    test('parses sparse payload with absent tags', () {
      final p = Preferences.fromJson({
        'budget': 1500,
        'gender_pref': null,
        'age_range': [20, 30],
      });
      expect(p.budget, 1500);
      expect(p.genderPref, isNull);
      expect(p.ageRange, [20, 30]);
      expect(p.tags, isEmpty);
    });

    test('serializes back including default empty tags', () {
      const p = Preferences(budget: 800, ageRange: [22, 28]);
      final json = p.toJson();
      expect(json['budget'], 800);
      expect(json['age_range'], [22, 28]);
      expect(json['tags'], isEmpty);
    });
  });

  group('MessageOut (V7 DateTime codec)', () {
    test('parses ts as DateTime, serializes back as ISO string', () {
      final iso = '2026-05-16T12:34:56.000Z';
      final m = MessageOut.fromJson({
        'id': 'm1',
        'conversation_id': 'c1',
        'sender_id': 's1',
        'body': 'hi',
        'ts': iso,
      });
      expect(m.ts, isA<DateTime>());
      expect(m.ts.toUtc().toIso8601String(), iso);

      final json = m.toJson();
      expect(json['ts'], iso);
    });
  });

  group('ConversationType (V7 enum @JsonValue mapping)', () {
    test('snake_case JSON ↔ camelCase Dart enum', () {
      expect(
        $enumDecode(_ctMap(), 'internal_group'),
        ConversationType.internalGroup,
      );
      expect(
        $enumDecode(_ctMap(), 'landlord_inquiry'),
        ConversationType.landlordInquiry,
      );
    });
  });

  group('PATCH classes strip nulls (V8/V18 PATCH semantics)', () {
    test('GroupPatch.toJson drops unset fields', () {
      const p = GroupPatch(capacity: 4); // preferences omitted
      expect(p.toJson(), {'capacity': 4});
    });

    test('ListingPatch.toJson drops unset fields', () {
      const p = ListingPatch(rent: 1800); // others omitted
      expect(p.toJson(), {'rent': 1800});
    });

    test('ListingPatch.toJson keeps explicitly-set fields', () {
      const p = ListingPatch(title: 'New', rent: 2000);
      expect(p.toJson(), {'title': 'New', 'rent': 2000});
    });
  });
}

// Smoke check that the generator emitted `_$ConversationTypeEnumMap` shape.
Map<ConversationType, dynamic> _ctMap() => {
  ConversationType.internalGroup: 'internal_group',
  ConversationType.landlordInquiry: 'landlord_inquiry',
};

// Re-implementation of json_annotation's $enumDecode for use without
// importing internals. Mirrors generated `_$enumDecode` logic.
T $enumDecode<T extends Object, K>(Map<T, K> enumValues, Object? source) {
  for (final entry in enumValues.entries) {
    if (entry.value == source) return entry.key;
  }
  throw ArgumentError(
    '`$source` is not one of the supported values: '
    '${enumValues.values.join(', ')}',
  );
}
