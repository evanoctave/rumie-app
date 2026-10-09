import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:roomie/di/locator.dart';
import 'package:roomie/domain/entities/entities.dart';
import 'package:roomie/domain/errors/api_exception.dart';
import 'package:roomie/domain/repositories/asset_repository.dart';
import 'package:roomie/domain/repositories/auth_repository.dart';
import 'package:roomie/domain/repositories/conversations_repository.dart';
import 'package:roomie/domain/repositories/discovery_repository.dart';
import 'package:roomie/domain/repositories/listings_repository.dart';
import 'package:roomie/screens/auth/login_screen.dart';
import 'package:roomie/screens/listings_screen.dart';
import 'package:roomie/screens/matches_screen.dart';
import 'package:roomie/state/auth_provider.dart';

// ── Fakes ─────────────────────────────────────────────────────────────────────

class _FakeAuth implements AuthRepository {
  Object? loginError;

  @override
  Future<TokensOut> login(LoginIn body) async {
    if (loginError != null) throw loginError!;
    return const TokensOut(access: 'a', refresh: 'r');
  }

  @override
  Future<RegisterOut> register(RegisterIn body) => throw UnimplementedError();
  @override
  Future<UserOut> me() => throw UnimplementedError();
  @override
  Future<bool> hasSession() async => false;
  @override
  Future<void> logout() async {}
}

class _FakeDiscovery implements DiscoveryRepository {
  List<ListingOut> listings = const [];

  @override
  Future<List<GroupOut>> discoverGroups({int limit = 20}) async => [];
  @override
  Future<List<ListingOut>> discoverListings({int limit = 20}) async => listings;
}

class _FakeListings implements ListingsRepository {
  final Map<String, ListingOut> byId = {};
  Object? createError;

  @override
  Future<ListingOut> create(ListingCreate body) async =>
      throw createError ?? UnimplementedError();
  @override
  Future<ListingOut> get(String listingId) async =>
      byId[listingId] ?? (throw const ServerException('nf', statusCode: 404));
  @override
  Future<ListingOut> patch(String listingId, ListingPatch body) =>
      throw UnimplementedError();
  @override
  Future<void> delete(String listingId) => throw UnimplementedError();
}

class _FakeConversations implements ConversationsRepository {
  Future<List<ConversationOut>> Function() list = () async => [];

  @override
  Future<List<ConversationOut>> listConversations() => list();
  @override
  Future<List<MessageOut>> listMessages(String convId,
          {int limit = 50, DateTime? before}) async =>
      [];
  @override
  Future<MessageOut> sendMessage(String convId, String body) =>
      throw UnimplementedError();
}

class _FakeAssets implements AssetRepository {
  @override
  Future<PresignOut> presign({required AssetKind kind, required String contentType}) =>
      throw UnimplementedError();
  @override
  Future<String> upload({
    required AssetKind kind,
    required Uint8List bytes,
    required String contentType,
  }) =>
      throw UnimplementedError();
}

ListingOut _listing(String id, String title, String description) => ListingOut(
      id: id,
      landlordId: 'll',
      title: title,
      description: description,
      rent: 1500,
      location: 'Westwood',
      photoUrls: const [],
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  late _FakeAuth auth;
  late _FakeDiscovery discovery;
  late _FakeListings listings;
  late _FakeConversations conversations;

  setUp(() async {
    await locator.reset();
    auth = _FakeAuth();
    discovery = _FakeDiscovery();
    listings = _FakeListings();
    conversations = _FakeConversations();
    locator
      ..registerSingleton<AuthRepository>(auth)
      ..registerSingleton<DiscoveryRepository>(discovery)
      ..registerSingleton<ListingsRepository>(listings)
      ..registerSingleton<ConversationsRepository>(conversations)
      ..registerSingleton<AssetRepository>(_FakeAssets());
  });

  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('Login: 422 shows the server message under the field (V5)',
      (tester) async {
    auth.loginError = const ValidationException({
      'email': ['value is not a valid email address'],
    });
    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => AuthProvider.deferred(),
      child: const MaterialApp(home: LoginScreen()),
    ));
    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.co');
    await tester.enterText(find.byType(TextFormField).at(1), 'whatever');
    await tester.tap(find.text('Sign in'));
    await settle(tester);

    expect(find.text('value is not a valid email address'), findsOneWidget);
  });

  testWidgets('Login: 401 → friendly snackbar, no raw error text',
      (tester) async {
    auth.loginError = const UnauthorizedException();
    await tester.pumpWidget(ChangeNotifierProvider(
      create: (_) => AuthProvider.deferred(),
      child: const MaterialApp(home: LoginScreen()),
    ));
    await tester.enterText(find.byType(TextFormField).at(0), 'a@b.co');
    await tester.enterText(find.byType(TextFormField).at(1), 'wrong');
    await tester.tap(find.text('Sign in'));
    await settle(tester);

    expect(find.text('Incorrect email or password.'), findsOneWidget);
  });

  testWidgets('Listings: renders API listings and filters by type',
      (tester) async {
    discovery.listings = [
      _listing(
        'l1',
        'Bright room',
        ListingMeta.encode(
          type: 'Room',
          bedsBaths: '1 bed / 1 bath',
          availableDate: 'Now',
        ),
      ),
      _listing('l2', 'Modern studio', 'No metadata here'),
    ];
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ListingsScreen())),
    );
    await settle(tester);

    expect(find.text('Bright room'), findsOneWidget);
    expect(find.text('Modern studio'), findsOneWidget);
    expect(find.text('1 bed / 1 bath'), findsOneWidget);
    expect(find.text('Available Now'), findsOneWidget);

    await tester.tap(find.text('Studio').first);
    await settle(tester);
    expect(find.text('Bright room'), findsNothing);
    expect(find.text('Modern studio'), findsOneWidget);
  });

  testWidgets('Listings: empty API result → empty state', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ListingsScreen())),
    );
    await settle(tester);
    expect(find.text('No listings yet. Check back soon.'), findsOneWidget);
  });

  testWidgets('Matches: conversations become tiles; count reported',
      (tester) async {
    listings.byId['l1'] = _listing('l1', 'Bright room', '');
    conversations.list = () async => const [
          ConversationOut(
            id: 'c1',
            type: ConversationType.landlordInquiry,
            participants: ['me', 'landlord'],
            groupId: 'g1',
            listingId: 'l1',
          ),
          ConversationOut(
            id: 'c2',
            type: ConversationType.internalGroup,
            participants: ['me', 'u2'],
            groupId: 'g1',
            listingId: null,
          ),
        ];
    int? reported;
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(body: MatchesScreen(onLoaded: (c) => reported = c)),
    ));
    await settle(tester);

    expect(find.text('Bright room'), findsOneWidget);
    expect(find.text('Group chat'), findsOneWidget);
    expect(reported, 2);
  });

  testWidgets('Matches: error state with retry', (tester) async {
    var calls = 0;
    conversations.list = () async {
      calls++;
      if (calls == 1) throw const ServerException('Server is down.');
      return const [];
    };
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: MatchesScreen())),
    );
    await settle(tester);
    expect(find.text('Server is down.'), findsOneWidget);

    await tester.tap(find.text('Try again'));
    await settle(tester);
    expect(find.text('No matches yet'), findsOneWidget);
  });
}
