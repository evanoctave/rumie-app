// lib/api/api_models.dart

class UserOut {
  final String id;
  final String email;
  final String? phone;
  final String role;
  final int age;
  final String gender;
  final String? profilePhotoUrl;

  const UserOut({
    required this.id,
    required this.email,
    required this.phone,
    required this.role,
    required this.age,
    required this.gender,
    required this.profilePhotoUrl,
  });

  factory UserOut.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserOut(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      age: json['age'],
      gender: json['gender'],
      profilePhotoUrl: json['profile_photo_url'],
    );
  }
}

class ListingOut {
  final String id;
  final String landlordId;
  final String title;
  final String description;
  final int rent;
  final String location;
  final List<String> photoUrls;

  const ListingOut({
    required this.id,
    required this.landlordId,
    required this.title,
    required this.description,
    required this.rent,
    required this.location,
    required this.photoUrls,
  });

  factory ListingOut.fromJson(
    Map<String, dynamic> json,
  ) {
    return ListingOut(
      id: json['id'],
      landlordId: json['landlord_id'],
      title: json['title'],
      description: json['description'],
      rent: json['rent'],
      location: json['location'],
      photoUrls: List<String>.from(
        json['photo_urls'] ?? [],
      ),
    );
  }
}

class GroupOut {
  final String id;
  final String adminId;
  final List<String> members;
  final Map<String, dynamic> preferences;
  final int capacity;

  const GroupOut({
    required this.id,
    required this.adminId,
    required this.members,
    required this.preferences,
    required this.capacity,
  });

  factory GroupOut.fromJson(
    Map<String, dynamic> json,
  ) {
    return GroupOut(
      id: json['id'],
      adminId: json['admin_id'],
      members: List<String>.from(
        json['members'] ?? [],
      ),
      preferences: Map<String, dynamic>.from(
        json['preferences'] ?? {},
      ),
      capacity: json['capacity'],
    );
  }
}

class ConversationOut {
  final String id;
  final List<String> memberIds;

  const ConversationOut({
    required this.id,
    required this.memberIds,
  });

  factory ConversationOut.fromJson(
    Map<String, dynamic> json,
  ) {
    return ConversationOut(
      id: json['id'],
      memberIds: List<String>.from(
        json['member_ids'] ?? [],
      ),
    );
  }
}

class MessageOut {
  final String id;
  final String conversationId;
  final String senderId;
  final String body;

  const MessageOut({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.body,
  });

  factory MessageOut.fromJson(
    Map<String, dynamic> json,
  ) {
    return MessageOut(
      id: json['id'],
      conversationId: json['conversation_id'],
      senderId: json['sender_id'],
      body: json['body'],
    );
  }
}
