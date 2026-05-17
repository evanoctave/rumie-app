class ApiEndpoints {
  static const String baseUrl = 'https://rumie.xyz';

  static const String health = '/api/v1/health';

  static const String register = '/api/v1/auth/register';
  static const String login = '/api/v1/auth/login';
  static const String refresh = '/api/v1/auth/refresh';
  static const String me = '/api/v1/auth/me';

  static const String myGroup = '/api/v1/groups/me';
  static const String leaveGroup = '/api/v1/groups/me/leave';
  static const String createInvite = '/api/v1/groups/me/invites';

  static String acceptInvite(String inviteId) =>
      '/api/v1/invites/$inviteId/accept';

  static String rejectInvite(String inviteId) =>
      '/api/v1/invites/$inviteId/reject';

  static const String listings = '/api/v1/listings';

  static String listingById(String listingId) => '/api/v1/listings/$listingId';

  static const String discoverGroups = '/api/v1/discovery/groups';
  static const String discoverListings = '/api/v1/discovery/listings';

  static const String swipes = '/api/v1/swipes';

  static const String inquiries = '/api/v1/inquiries';

  static String acceptInquiry(String inquiryId) =>
      '/api/v1/inquiries/$inquiryId/accept';

  static String rejectInquiry(String inquiryId) =>
      '/api/v1/inquiries/$inquiryId/reject';

  static const String conversations = '/api/v1/conversations';

  static String conversationMessages(String convId) =>
      '/api/v1/conversations/$convId/messages';

  static const String presignUpload = '/api/v1/uploads/presign';
}
