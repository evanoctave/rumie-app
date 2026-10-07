import '../domain/entities/entities.dart';

/// Sample entities for the demo launcher. Shapes match what the API serves.
class DemoData {
  DemoData._();

  static const String myId = 'demo-me';

  static const user = UserOut(
    id: myId,
    email: 'you@rumie.app',
    phone: null,
    role: Role.rumie,
    age: 23,
    gender: Gender.other,
    profilePhotoUrl: null,
  );

  static const myGroup = GroupOut(
    id: 'demo-group-me',
    adminId: myId,
    members: [myId],
    preferences: Preferences(budget: 1500, tags: ['Night owl', 'Loves cooking']),
    capacity: 2,
  );

  static const groups = [
    GroupOut(
      id: 'demo-marcus',
      adminId: 'u-marcus',
      members: ['u-marcus'],
      preferences: Preferences(budget: 1200, ageRange: [22, 26], tags: ['Very tidy', 'Night owl', 'Gamer', 'Studious']),
      capacity: 2,
    ),
    GroupOut(
      id: 'demo-jordan',
      adminId: 'u-jordan',
      members: ['u-jordan'],
      preferences: Preferences(budget: 1500, ageRange: [24, 30], tags: ['Works from home', 'Early bird', 'Non-smoker']),
      capacity: 2,
    ),
    GroupOut(
      id: 'demo-malik',
      adminId: 'u-malik',
      members: ['u-malik', 'u-ana'],
      preferences: Preferences(budget: 900, ageRange: [21, 25], tags: ['Creative', 'Loves cooking', 'Night owl', 'Vegetarian']),
      capacity: 3,
    ),
    GroupOut(
      id: 'demo-darius',
      adminId: 'u-darius',
      members: ['u-darius'],
      preferences: Preferences(budget: 1800, ageRange: [25, 32], tags: ['Gym rat', 'Early bird', 'Very tidy']),
      capacity: 2,
    ),
    GroupOut(
      id: 'demo-devon',
      adminId: 'u-devon',
      members: ['u-devon', 'u-sam', 'u-lee'],
      preferences: Preferences(budget: 1100, tags: ['Music lover', 'Night owl', 'Non-smoker']),
      capacity: 4,
    ),
  ];

  /// Portraits for the demo cards. Keyed by group id; see [AvatarStyle.photoOverrides].
  static const photos = {
    'demo-marcus': 'assets/images/evan_1.jpg',
    'demo-jordan': 'assets/images/evan_4.jpg',
    'demo-malik': 'assets/images/p_malik.jpg',
    'demo-darius': 'assets/images/p_darius.jpg',
    'demo-devon': 'assets/images/p_devon.jpg',
  };

  /// Groups that "like back" when swiped right.
  static const matchBack = {'demo-jordan', 'demo-devon'};

  static final listings = <ListingOut>[
    ListingOut(
      id: 'l1',
      landlordId: 'll1',
      title: 'Bright private room near campus',
      description: ListingMeta.encode(type: 'Room', bedsBaths: '1 bed / shared bath', availableDate: 'June 1'),
      rent: 1250,
      location: 'Westwood, Los Angeles',
      photoUrls: const [],
    ),
    ListingOut(
      id: 'l2',
      landlordId: 'll1',
      title: 'Spacious apartment with shared kitchen',
      description: ListingMeta.encode(type: 'Apartment', bedsBaths: '2 bed / 1 bath', availableDate: 'Now'),
      rent: 1800,
      location: 'Koreatown, Los Angeles',
      photoUrls: const [],
    ),
    ListingOut(
      id: 'l3',
      landlordId: 'll2',
      title: 'Quiet condo with home office',
      description: ListingMeta.encode(type: 'Condo', bedsBaths: '2 bed / 2 bath', availableDate: 'July 10'),
      rent: 2100,
      location: 'Pasadena, CA',
      photoUrls: const [],
    ),
    ListingOut(
      id: 'l4',
      landlordId: 'll2',
      title: 'Duplex room with private backyard',
      description: ListingMeta.encode(type: 'Duplex', bedsBaths: '1 bed / 1 bath', availableDate: 'August 1'),
      rent: 1450,
      location: 'El Sereno, Los Angeles',
      photoUrls: const [],
    ),
    ListingOut(
      id: 'l5',
      landlordId: 'll3',
      title: 'Modern studio in downtown',
      description: ListingMeta.encode(type: 'Studio', bedsBaths: 'Studio / 1 bath', availableDate: 'Now'),
      rent: 1650,
      location: 'DTLA, Los Angeles',
      photoUrls: const [],
    ),
  ];

  static const conversations = [
    ConversationOut(
      id: 'c1',
      type: ConversationType.internalGroup,
      participants: [myId, 'u-jordan'],
      groupId: 'demo-group-me',
      listingId: null,
    ),
    ConversationOut(
      id: 'c2',
      type: ConversationType.landlordInquiry,
      participants: [myId, 'll1'],
      groupId: 'demo-group-me',
      listingId: 'l1',
    ),
  ];

  static List<RoommateCandidate> get candidates =>
      groups.map(RoommateCandidate.fromGroup).toList();

  static List<MatchSummary> get matches => [
        MatchSummary.fromConversation(conversations[0]),
        MatchSummary.fromConversation(conversations[1], listing: listings[0]),
      ];
}
