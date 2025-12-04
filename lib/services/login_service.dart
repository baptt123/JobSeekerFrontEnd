import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user-token-entity.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart'; // ✅ Import DioClient

class LoginService {
  // Sử dụng DioClient cho các request thông thường
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/auth');
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 1. LOGIN
  Future<UserToken?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = UserToken.fromJson(response.data);
        await _saveTokens(token);
        return token;
      }
      return null;
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Đăng nhập thất bại';
      throw Exception(msg);
    }
  }

  // 2. AUTO LOGIN (Giữ nguyên logic riêng để check Refresh Token lúc mở app)
  Future<UserToken?> tryAutoLogin() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) return null;

    try {
      // Dùng Dio() thường để tránh vòng lặp interceptor của DioClient
      final dio = Dio(BaseOptions(baseUrl: '${ConstantAPI.baseUrl}/auth'));
      final response = await dio.post(
        '/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = UserToken.fromJson(response.data);
        await _saveTokens(token);
        return token;
      }
    } catch (e) {
      await logout();
    }
    return null;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<void> _saveTokens(UserToken token) async {
    await _storage.write(key: 'accessToken', value: token.accessToken);
    await _storage.write(key: 'refreshToken', value: token.refreshToken);
    await _storage.write(key: 'userId', value: token.userId.toString());
  }
}