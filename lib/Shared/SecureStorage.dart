import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _secureStorage = FlutterSecureStorage();

class TokenStorage {
  static const _refreshKey = 'refresh_token';
  static const _accessKey  = 'access_token';

  static Future<void> writeRefreshToken(String token) =>
      _secureStorage.write(key: _refreshKey, value: token);

  static Future<String?> readRefreshToken() =>
      _secureStorage.read(key: _refreshKey);

  static Future<void> deleteRefreshToken() =>
      _secureStorage.delete(key: _refreshKey);

  static Future<void> writeAccessToken(String token) =>
      _secureStorage.write(key: _accessKey, value: token);

  static Future<String?> readAccessToken() =>
      _secureStorage.read(key: _accessKey);

  static Future<void> deleteAccessToken() =>
      _secureStorage.delete(key: _accessKey);
}
