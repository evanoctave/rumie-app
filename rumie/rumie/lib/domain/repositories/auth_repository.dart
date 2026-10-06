import '../../data/models/login_in.dart';
import '../../data/models/register_in.dart';
import '../../data/models/register_out.dart';
import '../../data/models/tokens_out.dart';
import '../../data/models/user_out.dart';

abstract class AuthRepository {
  Future<TokensOut> login(LoginIn body);
  Future<RegisterOut> register(RegisterIn body);
  Future<UserOut> me();

  /// Whether an access token is stored locally (cold-start check). Does not
  /// hit the network; validity is established by a following [me] call.
  Future<bool> hasSession();

  /// Client-side only: clears the local token store. The API has no logout
  /// endpoint (V15).
  Future<void> logout();
}
