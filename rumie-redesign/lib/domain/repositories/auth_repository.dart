import '../../data/models/login_in.dart';
import '../../data/models/register_in.dart';
import '../../data/models/register_out.dart';
import '../../data/models/tokens_out.dart';
import '../../data/models/user_out.dart';

abstract class AuthRepository {
  Future<TokensOut> login(LoginIn body);
  Future<RegisterOut> register(RegisterIn body);
  Future<UserOut> me();

  /// Client-side only: clears the local token store. The API has no logout
  /// endpoint (V15).
  Future<void> logout();
}
