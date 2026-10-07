import 'package:dio/dio.dart';

import '../../domain/repositories/auth_repository.dart';
import '../api/exceptions.dart';
import '../api/token_store.dart';
import '../models/login_in.dart';
import '../models/register_in.dart';
import '../models/register_out.dart';
import '../models/tokens_out.dart';
import '../models/user_out.dart';
import 'repository_helpers.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final TokenStore _tokenStore;

  AuthRepositoryImpl(this._dio, this._tokenStore);

  @override
  Future<TokensOut> login(LoginIn body) => callApi(() async {
        final r = await _dio.post<dynamic>(
          '/auth/login',
          data: body.toJson(),
        );
        final tokens = TokensOut.fromJson(r.data as Map<String, dynamic>);
        await _persist(tokens);
        return tokens;
      });

  @override
  Future<RegisterOut> register(RegisterIn body) => callApi(() async {
        final r = await _dio.post<dynamic>(
          '/auth/register',
          data: body.toJson(),
        );
        final out = RegisterOut.fromJson(r.data as Map<String, dynamic>);
        await _persist(out.tokens);
        return out;
      });

  @override
  Future<UserOut> me() => callApi(() async {
        final r = await _dio.get<dynamic>('/auth/me');
        return UserOut.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<bool> hasSession() async {
    try {
      final access = await _tokenStore.readAccess();
      return access != null && access.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<void> logout() async {
    await _tokenStore.clear();
  }

  /// V14: tokens must be stored before the call reports success. A storage
  /// failure fails the whole login/register (and leaves no half-written pair).
  Future<void> _persist(TokensOut tokens) async {
    try {
      await _tokenStore.write(access: tokens.access, refresh: tokens.refresh);
    } catch (_) {
      try {
        await _tokenStore.clear();
      } catch (_) {}
      throw const StorageException();
    }
  }
}
