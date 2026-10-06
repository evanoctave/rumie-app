import '../../data/models/conversation_out.dart';
import '../../data/models/conversation_type.dart';
import '../../data/models/listing_out.dart';

/// A row in the Matches tab: one server conversation plus display text.
///
/// Mutual matches surface as conversations (`internal_group` after a group
/// merge, `landlord_inquiry` after an accepted listing inquiry).
class MatchSummary {
  final ConversationOut conversation;
  final String title;
  final String subtitle;

  const MatchSummary({
    required this.conversation,
    required this.title,
    required this.subtitle,
  });

  String get id => conversation.id;

  factory MatchSummary.fromConversation(
    ConversationOut c, {
    ListingOut? listing,
  }) {
    final others = c.participants.length - 1;
    final people = '${others < 1 ? 1 : others} '
        '${others == 1 || others < 1 ? 'person' : 'people'}';
    switch (c.type) {
      case ConversationType.landlordInquiry:
        return MatchSummary(
          conversation: c,
          title: listing?.title ?? 'Listing inquiry',
          subtitle: listing != null
              ? '${listing.location} · \$${listing.rent}/mo'
              : 'Chat with the landlord · $people',
        );
      case ConversationType.internalGroup:
        return MatchSummary(
          conversation: c,
          title: 'Group chat',
          subtitle: 'Your roommate group · $people',
        );
    }
  }
}
