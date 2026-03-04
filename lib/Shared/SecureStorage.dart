import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

final _secureStorage = FlutterSecureStorage();

class TokenStorage {
  static const _refreshKey = 'refresh_token';
  static const _accessKey = 'access_token';
  static const _roleKey = 'role_key';

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

  static Future<String?> readRole() => _secureStorage.read(key: _roleKey);

  static Future<void> writeRoles(String token) async {
    final roles = List<String>.from(JwtDecoder.decode(token)['roles'] ?? []);
    String? role;
    if (roles.contains('Coach')) {
      role = 'Coach';
    } else if (roles.contains('User')) {
      role = 'User';
    }
    if (role != null) {
      await _secureStorage.write(key: 'role_key', value: role);
    }
  }
}
