// lib/services/login_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user-token-entity.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

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
      // 🔥 XỬ LÝ LỖI CHI TIẾT TỪ BACKEND
      final msg = e.response?.data['message'] ?? 'Đăng nhập thất bại';

      // Nếu tài khoản bị cấm (Forbidden - 403)
      if (e.response?.statusCode == 403) {
        throw Exception("403: $msg");
      }

      throw Exception(msg);
    }
  }

  // 2. AUTO LOGIN
  Future<UserToken?> tryAutoLogin() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) return null;

    try {
      // Thiết lập timeout ngắn cho Auto Login
      final dio = Dio(BaseOptions(
        baseUrl: '${ConstantAPI.baseUrl}/auth',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ));

      final response = await dio.post(
        '/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = UserToken.fromJson(response.data);
        await _saveTokens(token);
        return token;
      }
    } on DioException catch (e) {
      // Nếu lỗi 400/401/403 (Token sai/hết hạn/bị cấm) -> Xóa token để đăng nhập lại
      if (e.response?.statusCode == 400 ||
          e.response?.statusCode == 401 ||
          e.response?.statusCode == 403) {
        await logout();
      }
      else {
        print("⚠️ Lỗi kết nối khi Auto Login: ${e.message}. Vào App với chế độ Khách/Offline.");
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