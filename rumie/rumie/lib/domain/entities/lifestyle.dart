/// Lifestyle + preference enums shared by roommate profiles and the
/// compatibility engine. Pure Dart — no Flutter imports.
library;

enum StudentStatus {
  incomingFreshman('Incoming freshman'),
  undergrad('Undergrad'),
  transfer('Transfer student'),
  gradStudent('Grad student'),
  youngProfessional('Young professional');

  const StudentStatus(this.label);
  final String label;
}

enum HousingIntent {
  hasPlace('Has a place'),
  needsPlace('Needs a place'),
  lookingTogether('Looking together'),
  openToOptions('Open to options');

  const HousingIntent(this.label);
  final String label;
}

enum HousingType {
  apartment('Apartment'),
  house('House'),
  studio('Studio'),
  dorm('Dorm'),
  any('Open to any');

  const HousingType(this.label);
  final String label;
}

enum CleanlinessLevel {
  relaxed('Relaxed'),
  average('Pretty tidy'),
  veryTidy('Very tidy');

  const CleanlinessLevel(this.label);
  final String label;
}

enum SleepSchedule {
  earlyBird('Early bird'),
  flexible('Flexible'),
  nightOwl('Night owl');

  const SleepSchedule(this.label);
  final String label;
}

enum NoiseTolerance {
  quiet('Quiet'),
  moderate('Moderate'),
  lively('Lively');

  const NoiseTolerance(this.label);
  final String label;
}

enum GuestPreference {
  rarely('Rarely hosts'),
  sometimes('Sometimes hosts'),
  often('Often hosts');

  const GuestPreference(this.label);
  final String label;
}

enum StudyHabits {
  atLibrary('Studies out'),
  atHome('Studies at home'),
  mixed('Mix of both');

  const StudyHabits(this.label);
  final String label;
}

enum PetPreference {
  noPets('No pets'),
  okWithPets('Okay with pets'),
  hasPets('Has pets');

  const PetPreference(this.label);
  final String label;
}

enum SmokingPreference {
  no('Non-smoker'),
  outdoorOnly('Outside only'),
  yes('Smoker');

  const SmokingPreference(this.label);
  final String label;
}

enum DrinkingPreference {
  never('Doesn\'t drink'),
  socially('Drinks socially'),
  often('Likes to party');

  const DrinkingPreference(this.label);
  final String label;
}

enum VerificationStatus {
  unverified('Unverified'),
  pending('Verification pending'),
  verifiedStudent('Verified student');

  const VerificationStatus(this.label);
  final String label;
}
