import 'package:flutter_test/flutter_test.dart';
import 'package:roomie/domain/entities/lifestyle.dart';
import 'package:roomie/domain/entities/roommate_profile.dart';
import 'package:roomie/domain/services/compatibility_service.dart';

RoommateProfile _profile({
  String id = 'p1',
  String school = 'UCLA',
  int budgetMin = 900,
  int budgetMax = 1400,
  List<String> neighborhoods = const ['Westwood'],
  DateTime? moveIn,
  HousingType housingType = HousingType.apartment,
  CleanlinessLevel cleanliness = CleanlinessLevel.average,
  SleepSchedule sleep = SleepSchedule.flexible,
  NoiseTolerance noise = NoiseTolerance.quiet,
  PetPreference pets = PetPreference.okWithPets,
  SmokingPreference smoking = SmokingPreference.no,
  List<String> interests = const ['Fitness', 'Cooking'],
}) {
  return RoommateProfile(
    id: id,
    name: 'Test',
    age: 21,
    school: school,
    major: 'CS',
    studentStatus: StudentStatus.undergrad,
    year: 'Junior',
    avatarAsset: '',
    bio: 'bio',
    interests: interests,
    budgetMin: budgetMin,
    budgetMax: budgetMax,
    preferredNeighborhoods: neighborhoods,
    moveInDate: moveIn ?? DateTime(2026, 9, 1),
    housingTypePreference: housingType,
    cleanliness: cleanliness,
    sleepSchedule: sleep,
    noiseTolerance: noise,
    petPreference: pets,
    smokingPreference: smoking,
    createdAt: DateTime(2026, 1, 1),
  );
}

void main() {
  const service = CompatibilityService();

  group('CompatibilityService', () {
    test('identical profiles score near 100 with reasons', () {
      final result = service.score(_profile(), _profile(id: 'p2'));
      expect(result.score, greaterThanOrEqualTo(90));
      expect(result.reasons, isNotEmpty);
      expect(result.reasons, contains('Your budgets overlap'));
      expect(result.reasons, contains('Both at UCLA'));
    });

    test('score is always within 0–100', () {
      final clash = _profile(
        id: 'p2',
        school: 'USC',
        budgetMin: 3000,
        budgetMax: 4000,
        neighborhoods: ['Downtown'],
        moveIn: DateTime(2027, 6, 1),
        housingType: HousingType.house,
        cleanliness: CleanlinessLevel.relaxed,
        sleep: SleepSchedule.nightOwl,
        noise: NoiseTolerance.lively,
        pets: PetPreference.hasPets,
        smoking: SmokingPreference.yes,
        interests: ['Skydiving'],
      );
      final result = service.score(_profile(), clash);
      expect(result.score, inInclusiveRange(0, 100));
      expect(result.score, lessThan(50));
    });

    test('non-overlapping budgets omit the budget reason', () {
      final result = service.score(
        _profile(),
        _profile(id: 'p2', budgetMin: 2000, budgetMax: 3000),
      );
      expect(result.reasons, isNot(contains('Your budgets overlap')));
    });

    test('pet conflict (no-pets vs has-pets) drops the pet credit', () {
      final noPets = _profile(pets: PetPreference.noPets);
      final hasPets = _profile(id: 'p2', pets: PetPreference.hasPets);
      final conflict = service.score(noPets, hasPets);

      final okPets = service.score(
        _profile(pets: PetPreference.okWithPets),
        hasPets,
      );
      expect(okPets.score, greaterThan(conflict.score));
    });

    test('shared interests are surfaced case-insensitively', () {
      final a = _profile(interests: ['fitness', 'Vinyl']);
      final b = _profile(id: 'p2', interests: ['Fitness', 'Chess']);
      expect(service.sharedInterests(a, b), ['Fitness']);
    });

    test('quiet pair earns the quiet-weeknights reason', () {
      final result = service.score(
        _profile(noise: NoiseTolerance.quiet),
        _profile(id: 'p2', noise: NoiseTolerance.quiet),
      );
      expect(result.reasons, contains('You both prefer quiet weeknights'));
    });
  });
}
