import 'package:dio/dio.dart';

import '../../domain/repositories/auth_repository.dart';
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
        await _tokenStore.write(access: tokens.access, refresh: tokens.refresh);
        return tokens;
      });

  @override
  Future<RegisterOut> register(RegisterIn body) => callApi(() async {
        final r = await _dio.post<dynamic>(
          '/auth/register',
          data: body.toJson(),
        );
        final out = RegisterOut.fromJson(r.data as Map<String, dynamic>);
        await _tokenStore.write(
          access: out.tokens.access,
          refresh: out.tokens.refresh,
        );
        return out;
      });

  @override
  Future<UserOut> me() => callApi(() async {
        final r = await _dio.get<dynamic>('/auth/me');
        return UserOut.fromJson(r.data as Map<String, dynamic>);
      });

  @override
  Future<void> logout() async {
    await _tokenStore.clear();
  }
}
