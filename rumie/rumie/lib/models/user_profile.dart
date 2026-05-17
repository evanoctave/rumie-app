class Pet {
  final String name;
  final String type;
  final int age;

  const Pet({required this.name, required this.type, this.age = 0});

  Pet copyWith({String? name, String? type, int? age}) => Pet(
        name: name ?? this.name,
        type: type ?? this.type,
        age: age ?? this.age,
      );
}

class UserProfile {
  final String name;
  final int age;
  final String bio;
  final String location;
  final int budgetMin;
  final int budgetMax;
  final String photoPath;
  final List<String> traits;
  final String moveIn;
  final bool haspets;
  final List<Pet> pets;
  final String schedule;
  final String tidiness;

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
    this.pets = const [],
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
    List<Pet>? pets,
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
      pets: pets ?? this.pets,
      schedule: schedule ?? this.schedule,
      tidiness: tidiness ?? this.tidiness,
    );
  }

  bool get isComplete =>
      name.isNotEmpty && age > 0 && bio.isNotEmpty && location.isNotEmpty;
}
