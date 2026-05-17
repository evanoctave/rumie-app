// lib/api/rumie_api.dart

import 'api_client.dart';
import 'api_endpoints.dart';
import 'api_models.dart';

class RumieApi {
  final ApiClient apiClient;

  const RumieApi({
    required this.apiClient,
  });

  Future<dynamic> health() {
    return apiClient.get(
      ApiEndpoints.health,
    );
  }

  Future<dynamic> register({
    required String email,
    required String password,
    required String role,
    required int age,
    required String gender,
    String? phone,
    String? profilePhotoUrl,
  }) {
    return apiClient.post(
      ApiEndpoints.register,
      body: {
        'email': email,
        'password': password,
        'role': role,
        'age': age,
        'gender': gender,
        'phone': phone,
        'profile_photo_url': profilePhotoUrl,
      },
    );
  }

  Future<dynamic> login({
    required String email,
    required String password,
  }) {
    return apiClient.post(
      ApiEndpoints.login,
      body: {
        'email': email,
        'password': password,
      },
    );
  }

  Future<dynamic> refresh() {
    return apiClient.post(
      ApiEndpoints.refresh,
    );
  }

  Future<UserOut> getMe() async {
    final json = await apiClient.get(
      ApiEndpoints.me,
    );

    return UserOut.fromJson(json);
  }

  Future<GroupOut> getMyGroup() async {
    final json = await apiClient.get(
      ApiEndpoints.myGroup,
    );

    return GroupOut.fromJson(json);
  }

  Future<GroupOut> updateMyGroup({
    required Map<String, dynamic> preferences,
    required int capacity,
  }) async {
    final json = await apiClient.patch(
      ApiEndpoints.myGroup,
      body: {
        'preferences': preferences,
        'capacity': capacity,
      },
    );

    return GroupOut.fromJson(json);
  }

  Future<dynamic> leaveGroup() {
    return apiClient.post(
      ApiEndpoints.leaveGroup,
    );
  }

  Future<dynamic> createInvite() {
    return apiClient.post(
      ApiEndpoints.createInvite,
    );
  }

  Future<dynamic> acceptInvite(String inviteId) {
    return apiClient.post(
      ApiEndpoints.acceptInvite(inviteId),
    );
  }

  Future<dynamic> rejectInvite(String inviteId) {
    return apiClient.post(
      ApiEndpoints.rejectInvite(inviteId),
    );
  }

  Future<List<ListingOut>> discoverListings() async {
    final json = await apiClient.get(
      ApiEndpoints.discoverListings,
    );

    return List<Map<String, dynamic>>.from(json)
        .map(ListingOut.fromJson)
        .toList();
  }

  Future<List<GroupOut>> discoverGroups() async {
    final json = await apiClient.get(
      ApiEndpoints.discoverGroups,
    );

    return List<Map<String, dynamic>>.from(json)
        .map(GroupOut.fromJson)
        .toList();
  }

  Future<ListingOut> createListing({
    required String title,
    required String description,
    required int rent,
    required String location,
    required List<String> photoUrls,
  }) async {
    final json = await apiClient.post(
      ApiEndpoints.listings,
      body: {
        'title': title,
        'description': description,
        'rent': rent,
        'location': location,
        'photo_urls': photoUrls,
      },
    );

    return ListingOut.fromJson(json);
  }

  Future<ListingOut> getListing(
    String listingId,
  ) async {
    final json = await apiClient.get(
      ApiEndpoints.listingById(listingId),
    );

    return ListingOut.fromJson(json);
  }

  Future<ListingOut> updateListing({
    required String listingId,
    String? title,
    String? description,
    int? rent,
    String? location,
    List<String>? photoUrls,
  }) async {
    final json = await apiClient.patch(
      ApiEndpoints.listingById(listingId),
      body: {
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (rent != null) 'rent': rent,
        if (location != null) 'location': location,
        if (photoUrls != null) 'photo_urls': photoUrls,
      },
    );

    return ListingOut.fromJson(json);
  }

  Future<dynamic> deleteListing(
    String listingId,
  ) {
    return apiClient.delete(
      ApiEndpoints.listingById(listingId),
    );
  }

  Future<dynamic> postSwipe({
    required String targetId,
    required String targetType,
    required String direction,
  }) {
    return apiClient.post(
      ApiEndpoints.swipes,
      body: {
        'target_id': targetId,
        'target_type': targetType,
        'direction': direction,
      },
    );
  }

  Future<dynamic> listInquiries() {
    return apiClient.get(
      ApiEndpoints.inquiries,
    );
  }

  Future<dynamic> acceptInquiry(
    String inquiryId,
  ) {
    return apiClient.post(
      ApiEndpoints.acceptInquiry(inquiryId),
    );
  }

  Future<dynamic> rejectInquiry(
    String inquiryId,
  ) {
    return apiClient.post(
      ApiEndpoints.rejectInquiry(inquiryId),
    );
  }

  Future<List<ConversationOut>> listConversations() async {
    final json = await apiClient.get(
      ApiEndpoints.conversations,
    );

    return List<Map<String, dynamic>>.from(json)
        .map(ConversationOut.fromJson)
        .toList();
  }

  Future<List<MessageOut>> listMessages(
    String conversationId,
  ) async {
    final json = await apiClient.get(
      ApiEndpoints.conversationMessages(
        conversationId,
      ),
    );

    return List<Map<String, dynamic>>.from(json)
        .map(MessageOut.fromJson)
        .toList();
  }

  Future<MessageOut> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    final json = await apiClient.post(
      ApiEndpoints.conversationMessages(
        conversationId,
      ),
      body: {
        'body': body,
      },
    );

    return MessageOut.fromJson(json);
  }

  Future<dynamic> presignUpload({
    required String filename,
    required String contentType,
  }) {
    return apiClient.post(
      ApiEndpoints.presignUpload,
      body: {
        'filename': filename,
        'content_type': contentType,
      },
    );
  }
}
