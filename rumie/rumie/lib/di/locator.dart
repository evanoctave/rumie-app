import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../data/api/dio_client.dart';
import '../data/api/token_store.dart';

final GetIt locator = GetIt.instance;

/// Registers infrastructure singletons. Repository registration lands in M4.
void setupLocator() {
  locator
    ..registerLazySingleton<TokenStore>(() => const SecureTokenStore())
    ..registerLazySingleton<Dio>(() => DioClient.create(locator<TokenStore>()));
}
