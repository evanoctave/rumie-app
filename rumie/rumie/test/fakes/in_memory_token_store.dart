import 'package:roomie/data/api/token_store.dart';

class InMemoryTokenStore implements TokenStore {
  String? _access;
  String? _refresh;

  InMemoryTokenStore({String? access, String? refresh})
    : _access = access,
      _refresh = refresh;

  @override
  Future<String?> readAccess() async => _access;

  @override
  Future<String?> readRefresh() async => _refresh;

  @override
  Future<void> write({required String access, required String refresh}) async {
    _access = access;
    _refresh = refresh;
  }

  @override
  Future<void> clear() async {
    _access = null;
    _refresh = null;
  }
}
