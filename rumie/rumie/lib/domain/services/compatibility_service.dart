import '../entities/lifestyle.dart';
import '../entities/roommate_profile.dart';

/// Result of comparing two roommate profiles.
class CompatibilityResult {
  /// 0–100.
  final int score;

  /// Human-readable "why you match" lines, strongest first.
  final List<String> reasons;

  const CompatibilityResult({required this.score, required this.reasons});
}

/// Local, rule-based compatibility scoring.
///
/// Deliberately modular: the Discover feed only consumes
/// [CompatibilityResult], so a backend/ML ranker can replace this class
/// without UI changes.
class CompatibilityService {
  const CompatibilityService();

  /// Weights sum to 100 so the score reads as a percentage.
  static const _wBudget = 16;
  static const _wSchool = 12;
  static const _wNeighborhood = 8;
  static const _wMoveIn = 10;
  static const _wHousingType = 6;
  static const _wCleanliness = 12;
  static const _wSleep = 10;
  static const _wNoise = 7;
  static const _wGuests = 5;
  static const _wPets = 5;
  static const _wSmoking = 4;
  static const _wDrinking = 3;
  static const _wInterests = 2;

  CompatibilityResult score(RoommateProfile me, RoommateProfile other) {
    var total = 0.0;
    final reasons = <String>[];

    // Budget overlap.
    final overlapLow =
        me.budgetMin > other.budgetMin ? me.budgetMin : other.budgetMin;
    final overlapHigh =
        me.budgetMax < other.budgetMax ? me.budgetMax : other.budgetMax;
    if (overlapHigh >= overlapLow) {
      final myRange = me.budgetMax - me.budgetMin;
      final ratio =
          myRange <= 0
              ? 1.0
              : ((overlapHigh - overlapLow) / myRange).clamp(0.0, 1.0);
      total += _wBudget * (0.5 + 0.5 * ratio);
      reasons.add('Your budgets overlap');
    }

    // School.
    if (me.school.isNotEmpty && me.school == other.school) {
      total += _wSchool;
      reasons.add('Both at ${other.school}');
    }

    // Neighborhoods.
    final sharedHoods = me.preferredNeighborhoods.toSet().intersection(
      other.preferredNeighborhoods.toSet(),
    );
    if (sharedHoods.isNotEmpty) {
      total += _wNeighborhood;
      reasons.add('Both looking in ${sharedHoods.first}');
    }

    // Move-in proximity (full credit within 30 days, fades to 0 at 120).
    final daysApart = me.moveInDate.difference(other.moveInDate).inDays.abs();
    if (daysApart <= 120) {
      final factor = daysApart <= 30 ? 1.0 : 1 - (daysApart - 30) / 90;
      total += _wMoveIn * factor;
      if (daysApart <= 45) reasons.add('Similar move-in timeline');
    }

    // Housing type.
    if (me.housingTypePreference == other.housingTypePreference ||
        me.housingTypePreference == HousingType.any ||
        other.housingTypePreference == HousingType.any) {
      total += _wHousingType;
      if (me.housingTypePreference == other.housingTypePreference &&
          me.housingTypePreference != HousingType.any) {
        reasons.add(
          'Both want ${me.housingTypePreference.label.toLowerCase()} living',
        );
      }
    }

    // Lifestyle scales: full credit for exact, half for adjacent.
    total += _scaled(
      me.cleanliness.index,
      other.cleanliness.index,
      _wCleanliness,
    );
    if (me.cleanliness == other.cleanliness) {
      reasons.add('Matching cleanliness standards');
    }

    total += _scaled(
      me.sleepSchedule.index,
      other.sleepSchedule.index,
      _wSleep,
    );
    if (me.sleepSchedule == other.sleepSchedule) {
      reasons.add('Similar sleep schedule');
    }

    total += _scaled(
      me.noiseTolerance.index,
      other.noiseTolerance.index,
      _wNoise,
    );
    if (me.noiseTolerance == other.noiseTolerance &&
        me.noiseTolerance == NoiseTolerance.quiet) {
      reasons.add('You both prefer quiet weeknights');
    }

    total += _scaled(
      me.guestPreference.index,
      other.guestPreference.index,
      _wGuests,
    );

    // Pets: hard conflict only when one has pets and the other wants none.
    final petConflict =
        (me.petPreference == PetPreference.noPets &&
            other.petPreference == PetPreference.hasPets) ||
        (other.petPreference == PetPreference.noPets &&
            me.petPreference == PetPreference.hasPets);
    if (!petConflict) {
      total += _wPets;
      if (me.petPreference != PetPreference.noPets &&
          other.petPreference != PetPreference.noPets) {
        reasons.add('Both are okay with pets');
      }
    }

    // Smoking.
    if (me.smokingPreference == other.smokingPreference) {
      total += _wSmoking;
      if (me.smokingPreference == SmokingPreference.no) {
        reasons.add('Both non-smokers');
      }
    } else if (me.smokingPreference != SmokingPreference.yes &&
        other.smokingPreference != SmokingPreference.yes) {
      total += _wSmoking / 2;
    }

    // Drinking.
    total += _scaled(
      me.drinkingPreference.index,
      other.drinkingPreference.index,
      _wDrinking,
    );

    // Shared interests.
    final shared = sharedInterests(me, other);
    if (shared.isNotEmpty) {
      total += _wInterests;
      reasons.add('Shared interest in ${shared.first.toLowerCase()}');
    }

    return CompatibilityResult(
      score: total.round().clamp(0, 100),
      reasons: reasons,
    );
  }

  List<String> sharedInterests(RoommateProfile a, RoommateProfile b) {
    final mine = a.interests.map((i) => i.toLowerCase()).toSet();
    return b.interests.where((i) => mine.contains(i.toLowerCase())).toList();
  }

  double _scaled(int a, int b, int weight) {
    final gap = (a - b).abs();
    if (gap == 0) return weight.toDouble();
    if (gap == 1) return weight / 2;
    return 0;
  }
}
