import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../data/api/dio_client.dart';
import '../data/api/token_store.dart';

final GetIt locator = GetIt.instance;

const _refreshDioName = 'refreshDio';

/// Registers infrastructure singletons. Repository registration lands in M4.
///
/// [onLogout] is fired after a 401 + failed refresh; the UI binds it in M5
/// to navigate back to login.
void setupLocator({void Function()? onLogout}) {
  locator
    ..registerLazySingleton<TokenStore>(() => const SecureTokenStore())
    ..registerLazySingleton<Dio>(
      DioClient.createRefreshDio,
      instanceName: _refreshDioName,
    )
    ..registerLazySingleton<Dio>(
      () => DioClient.create(
        tokenStore: locator<TokenStore>(),
        refreshDio: locator<Dio>(instanceName: _refreshDioName),
        mainDio: () => locator<Dio>(),
        onLogout: onLogout,
      ),
    );
}
