import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../data/api/dio_client.dart';
import '../data/api/token_store.dart';
import '../data/repositories/asset_repository_impl.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/conversations_repository_impl.dart';
import '../data/repositories/discovery_repository_impl.dart';
import '../data/repositories/groups_repository_impl.dart';
import '../data/repositories/inquiries_repository_impl.dart';
import '../data/repositories/listings_repository_impl.dart';
import '../data/mock/mock_housing_repository.dart';
import '../data/mock/mock_roommate_feed_repository.dart';
import '../data/mock/mock_roommate_group_repository.dart';
import '../data/repositories/swipe_repository_impl.dart';
import '../domain/repositories/asset_repository.dart';
import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/conversations_repository.dart';
import '../domain/repositories/discovery_repository.dart';
import '../domain/repositories/groups_repository.dart';
import '../domain/repositories/housing_repository.dart';
import '../domain/repositories/inquiries_repository.dart';
import '../domain/repositories/listings_repository.dart';
import '../domain/repositories/roommate_feed_repository.dart';
import '../domain/repositories/roommate_group_repository.dart';
import '../domain/repositories/swipe_repository.dart';
import '../domain/services/compatibility_service.dart';

final GetIt locator = GetIt.instance;

const _refreshDioName = 'refreshDio';
const _uploadPutDioName = 'uploadPutDio';

/// Registers infrastructure + repository singletons.
///
/// [onLogout] is fired after a 401 + failed refresh; the UI binds it in M5
/// to navigate back to login.
void setupLocator({void Function()? onLogout}) {
  locator
    // Infrastructure
    ..registerLazySingleton<TokenStore>(() => const SecureTokenStore())
    ..registerLazySingleton<Dio>(
      DioClient.createRefreshDio,
      instanceName: _refreshDioName,
    )
    ..registerLazySingleton<Dio>(
      DioClient.createUploadPutDio,
      instanceName: _uploadPutDioName,
    )
    ..registerLazySingleton<Dio>(
      () => DioClient.create(
        tokenStore: locator<TokenStore>(),
        refreshDio: locator<Dio>(instanceName: _refreshDioName),
        mainDio: () => locator<Dio>(),
        onLogout: onLogout,
      ),
    )
    // Repositories
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(locator<Dio>(), locator<TokenStore>()),
    )
    ..registerLazySingleton<GroupsRepository>(
      () => GroupsRepositoryImpl(locator<Dio>()),
    )
    ..registerLazySingleton<ListingsRepository>(
      () => ListingsRepositoryImpl(locator<Dio>()),
    )
    ..registerLazySingleton<DiscoveryRepository>(
      () => DiscoveryRepositoryImpl(locator<Dio>()),
    )
    ..registerLazySingleton<SwipeRepository>(
      () => SwipeRepositoryImpl(locator<Dio>()),
    )
    ..registerLazySingleton<InquiriesRepository>(
      () => InquiriesRepositoryImpl(locator<Dio>()),
    )
    ..registerLazySingleton<ConversationsRepository>(
      () => ConversationsRepositoryImpl(locator<Dio>()),
    )
    ..registerLazySingleton<AssetRepository>(
      () => AssetRepositoryImpl(
        locator<Dio>(),
        locator<Dio>(instanceName: _uploadPutDioName),
      ),
    )
    // Product-layer services + mock-backed repositories. These keep the UI
    // decoupled from the live API until the matching/housing endpoints ship;
    // swap the registrations here to go live (see README).
    ..registerLazySingleton<CompatibilityService>(
      () => const CompatibilityService(),
    )
    ..registerLazySingleton<RoommateFeedRepository>(
      MockRoommateFeedRepository.new,
    )
    ..registerLazySingleton<HousingRepository>(MockHousingRepository.new)
    ..registerLazySingleton<RoommateGroupRepository>(
      MockRoommateGroupRepository.new,
    );
}
