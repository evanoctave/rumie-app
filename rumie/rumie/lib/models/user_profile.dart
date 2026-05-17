class UserProfile {
  final String name;
  final int age;
  final String bio;
  final String location;
  final int budgetMin;
  final int budgetMax;
  final String photoPath; // local file path or empty
  final List<String> traits;
  final String moveIn;
  final bool haspets;
  final String schedule; // 'Early bird' | 'Night owl' | 'Flexible'
  final String tidiness; // 'Tidy' | 'Relaxed' | 'Very tidy'

  const UserProfile({
    required this.name,
    required this.age,
    required this.bio,
    required this.location,
    required this.budgetMin,
    required this.budgetMax,
    this.photoPath = '',
    this.traits = const [],
    this.moveIn = 'Flexible',
    this.haspets = false,
    this.schedule = 'Flexible',
    this.tidiness = 'Relaxed',
  });

  UserProfile copyWith({
    String? name,
    int? age,
    String? bio,
    String? location,
    int? budgetMin,
    int? budgetMax,
    String? photoPath,
    List<String>? traits,
    String? moveIn,
    bool? haspets,
    String? schedule,
    String? tidiness,
  }) {
    return UserProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      bio: bio ?? this.bio,
      location: location ?? this.location,
      budgetMin: budgetMin ?? this.budgetMin,
      budgetMax: budgetMax ?? this.budgetMax,
      photoPath: photoPath ?? this.photoPath,
      traits: traits ?? this.traits,
      moveIn: moveIn ?? this.moveIn,
      haspets: haspets ?? this.haspets,
      schedule: schedule ?? this.schedule,
      tidiness: tidiness ?? this.tidiness,
    );
  }

  bool get isComplete => name.isNotEmpty && age > 0 && bio.isNotEmpty && location.isNotEmpty;
}
