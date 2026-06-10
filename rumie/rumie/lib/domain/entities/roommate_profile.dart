import 'lifestyle.dart';

/// A full roommate profile. Pure Dart entity — rendering hints (gradients,
/// chip colors) are derived in `core/utils/profile_styles.dart`.
class RoommateProfile {
  final String id;
  final String name;
  final int age;
  final String school;
  final String major;
  final StudentStatus studentStatus;
  final String year;
  final String avatarAsset;
  final List<String> photoAssets;
  final String bio;
  final List<String> interests;
  final List<String> lifestyleTags;
  final int budgetMin;
  final int budgetMax;
  final List<String> preferredNeighborhoods;
  final double preferredDistanceFromCampusMiles;
  final DateTime moveInDate;
  final int leaseLengthMonths;
  final HousingType housingTypePreference;
  final HousingIntent housingIntent;
  final CleanlinessLevel cleanliness;
  final SleepSchedule sleepSchedule;
  final NoiseTolerance noiseTolerance;
  final GuestPreference guestPreference;
  final StudyHabits studyHabits;
  final PetPreference petPreference;
  final SmokingPreference smokingPreference;
  final DrinkingPreference drinkingPreference;
  final String genderRoommatePreference;
  final VerificationStatus verification;
  final DateTime createdAt;

  const RoommateProfile({
    required this.id,
    required this.name,
    required this.age,
    required this.school,
    required this.major,
    required this.studentStatus,
    required this.year,
    required this.avatarAsset,
    this.photoAssets = const [],
    required this.bio,
    this.interests = const [],
    this.lifestyleTags = const [],
    required this.budgetMin,
    required this.budgetMax,
    this.preferredNeighborhoods = const [],
    this.preferredDistanceFromCampusMiles = 2,
    required this.moveInDate,
    this.leaseLengthMonths = 12,
    this.housingTypePreference = HousingType.any,
    this.housingIntent = HousingIntent.openToOptions,
    this.cleanliness = CleanlinessLevel.average,
    this.sleepSchedule = SleepSchedule.flexible,
    this.noiseTolerance = NoiseTolerance.moderate,
    this.guestPreference = GuestPreference.sometimes,
    this.studyHabits = StudyHabits.mixed,
    this.petPreference = PetPreference.okWithPets,
    this.smokingPreference = SmokingPreference.no,
    this.drinkingPreference = DrinkingPreference.socially,
    this.genderRoommatePreference = 'No preference',
    this.verification = VerificationStatus.unverified,
    required this.createdAt,
  });

  bool get isVerified => verification == VerificationStatus.verifiedStudent;

  String get budgetLabel => '\$$budgetMin–\$$budgetMax/mo';

  String get moveInLabel {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[moveInDate.month - 1]} ${moveInDate.year}';
  }
}
