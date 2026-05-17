import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TokenStore {
  Future<String?> readAccess();
  Future<String?> readRefresh();
  Future<void> write({required String access, required String refresh});
  Future<void> clear();
}

class SecureTokenStore implements TokenStore {
  static const accessKey = 'rumie_access_token';
  static const refreshKey = 'rumie_refresh_token';

  final FlutterSecureStorage _storage;
  const SecureTokenStore([this._storage = const FlutterSecureStorage()]);

  @override
  Future<String?> readAccess() => _storage.read(key: accessKey);

  @override
  Future<String?> readRefresh() => _storage.read(key: refreshKey);

  @override
  Future<void> write({required String access, required String refresh}) async {
    await _storage.write(key: accessKey, value: access);
    await _storage.write(key: refreshKey, value: refresh);
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: accessKey);
    await _storage.delete(key: refreshKey);
  }
}
