import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static final _accessTokenKey = dotenv.env['ACCESS_TOKEN_KEY'] ?? 'ACCESS_TOKEN';
  static final _refreshTokenKey = dotenv.env['REFRESH_TOKEN_KEY'] ?? 'REFRESH_TOKEN';
  static const storage = FlutterSecureStorage();

  static Future<void> saveTokens(String access, String refresh) async {
    await storage.write(key: _accessTokenKey, value: access);
    await storage.write(key: _refreshTokenKey, value: refresh);
  }

  static Future<String?> getAccessToken() async {
    return await storage.read(key: _accessTokenKey);
  }

  static Future<String?> getRefreshToken() async {
    return await storage.read(key: _refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await storage.delete(key: _accessTokenKey);
    await storage.delete(key: _refreshTokenKey);
  }
}
