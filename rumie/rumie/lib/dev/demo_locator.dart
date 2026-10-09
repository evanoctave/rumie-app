import 'dart:typed_data';

import '../di/locator.dart';
import '../domain/entities/entities.dart';
import '../domain/repositories/asset_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/conversations_repository.dart';
import '../domain/repositories/discovery_repository.dart';
import '../domain/repositories/groups_repository.dart';
import '../domain/repositories/inquiries_repository.dart';
import '../domain/repositories/listings_repository.dart';
import '../domain/repositories/swipe_repository.dart';
import '../widgets/avatar_style.dart';
import 'demo_data.dart';

/// In-memory repositories for `--dart-define=RUMIE_DEMO=true`. Replaces
/// `setupLocator` so the UI runs with sample data and no backend.
void setupDemoLocator() {
  AvatarStyle.photoOverrides.addAll(DemoData.photos);
  final store = _DemoStore();
  locator
    ..registerSingleton<AuthRepository>(_DemoAuth())
    ..registerSingleton<DiscoveryRepository>(_DemoDiscovery(store))
    ..registerSingleton<SwipeRepository>(_DemoSwipe())
    ..registerSingleton<ConversationsRepository>(_DemoConversations(store))
    ..registerSingleton<ListingsRepository>(_DemoListings(store))
    ..registerSingleton<GroupsRepository>(_DemoGroups())
    ..registerSingleton<InquiriesRepository>(_DemoInquiries())
    ..registerSingleton<AssetRepository>(_DemoAssets());
}

class _DemoStore {
  final listings = List<ListingOut>.of(DemoData.listings);
  final conversations = List<ConversationOut>.of(DemoData.conversations);
  final messages = <String, List<MessageOut>>{
    'c1': [
      MessageOut(
        id: 'm1',
        conversationId: 'c1',
        senderId: 'u-jordan',
        body: 'Hey! Looks like we matched.',
        ts: DateTime.now().subtract(const Duration(minutes: 12)),
      ),
    ],
  };
  int _seq = 100;
  String nextId(String prefix) => '$prefix-${_seq++}';
}

class _DemoAuth implements AuthRepository {
  @override
  Future<bool> hasSession() async => true;
  @override
  Future<UserOut> me() async => DemoData.user;
  @override
  Future<TokensOut> login(LoginIn body) async => const TokensOut(access: 'demo', refresh: 'demo');
  @override
  Future<RegisterOut> register(RegisterIn body) async =>
      const RegisterOut(user: DemoData.user, tokens: TokensOut(access: 'demo', refresh: 'demo'));
  @override
  Future<void> logout() async {}
}

class _DemoDiscovery implements DiscoveryRepository {
  final _DemoStore store;
  _DemoDiscovery(this.store);
  @override
  Future<List<GroupOut>> discoverGroups({int limit = 20}) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return DemoData.groups;
  }

  @override
  Future<List<ListingOut>> discoverListings({int limit = 20}) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List.unmodifiable(store.listings);
  }
}

class _DemoSwipe implements SwipeRepository {
  @override
  Future<SwipeOut> swipe(SwipeIn body) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final matched = body.direction == SwipeDirection.right && DemoData.matchBack.contains(body.targetId);
    return SwipeOut(matched: matched, merge: matched ? {'group_id': body.targetId} : null);
  }
}

class _DemoConversations implements ConversationsRepository {
  final _DemoStore store;
  _DemoConversations(this.store);

  static const _replies = [
    'That works for me!',
    "What's your schedule like?",
    'I love that neighborhood too.',
    'Want to see the place this weekend?',
    'Do you cook a lot?',
  ];

  @override
  Future<List<ConversationOut>> listConversations() async => List.unmodifiable(store.conversations);

  @override
  Future<List<MessageOut>> listMessages(String convId, {int limit = 50, DateTime? before}) async =>
      List.unmodifiable(store.messages[convId] ?? const []);

  @override
  Future<MessageOut> sendMessage(String convId, String body) async {
    final msg = MessageOut(
      id: store.nextId('m'),
      conversationId: convId,
      senderId: DemoData.myId,
      body: body,
      ts: DateTime.now(),
    );
    (store.messages[convId] ??= []).add(msg);
    final conv = store.conversations.firstWhere((c) => c.id == convId);
    final other = conv.participants.firstWhere((p) => p != DemoData.myId, orElse: () => 'u-jordan');
    Future<void>.delayed(const Duration(milliseconds: 1600), () {
      store.messages[convId]!.add(MessageOut(
        id: store.nextId('m'),
        conversationId: convId,
        senderId: other,
        body: _replies[body.length % _replies.length],
        ts: DateTime.now(),
      ));
    });
    return msg;
  }
}

class _DemoListings implements ListingsRepository {
  final _DemoStore store;
  _DemoListings(this.store);

  @override
  Future<ListingOut> create(ListingCreate body) async {
    final l = ListingOut(
      id: store.nextId('l'),
      landlordId: DemoData.myId,
      title: body.title,
      description: body.description,
      rent: body.rent,
      location: body.location,
      photoUrls: body.photoUrls,
    );
    store.listings.insert(0, l);
    return l;
  }

  @override
  Future<ListingOut> get(String listingId) async => store.listings.firstWhere((l) => l.id == listingId);
  @override
  Future<ListingOut> patch(String listingId, ListingPatch body) => throw UnimplementedError();
  @override
  Future<void> delete(String listingId) async => store.listings.removeWhere((l) => l.id == listingId);
}

class _DemoGroups implements GroupsRepository {
  GroupOut _group = DemoData.myGroup;
  @override
  Future<GroupOut> getMyGroup() async => _group;
  @override
  Future<GroupOut> patchMyGroup(GroupPatch body) async {
    _group = GroupOut(
      id: _group.id,
      adminId: _group.adminId,
      members: _group.members,
      preferences: body.preferences ?? _group.preferences,
      capacity: body.capacity ?? _group.capacity,
    );
    return _group;
  }

  @override
  Future<void> leaveGroup() async {}
  @override
  Future<InviteOut> createInvite(InviteCreate body) => throw UnimplementedError();
  @override
  Future<InviteOut> acceptInvite(String inviteId) => throw UnimplementedError();
  @override
  Future<void> rejectInvite(String inviteId) async {}
}

class _DemoInquiries implements InquiriesRepository {
  @override
  Future<List<InquiryOut>> list({InquiryStatus? status}) async => const [];
  @override
  Future<Map<String, dynamic>> accept(String inquiryId) async => const {};
  @override
  Future<void> reject(String inquiryId) async {}
}

class _DemoAssets implements AssetRepository {
  @override
  Future<PresignOut> presign({required AssetKind kind, required String contentType}) =>
      throw UnimplementedError();
  @override
  Future<String> upload({required AssetKind kind, required Uint8List bytes, required String contentType}) async =>
      'assets/images/p_marcus.jpg';
}
