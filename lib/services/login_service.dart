import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user-token-entity.dart'; // Giữ nguyên model của bạn

class LoginService {
  // THAY ĐỔI ĐỊA CHỈ IP NẾU CẦN
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://192.168.67.109:3000/auth'));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Sửa tên constructor cho đúng với tên class
  LoginService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final accessToken = await _storage.read(key: 'accessToken');
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final isRefreshed = await _handleTokenRefresh();
          if (isRefreshed) {
            final retryRequest = await _retryRequest(error.requestOptions);
            return handler.resolve(retryRequest);
          }
        }
        handler.next(error);
      },
    ));
  }
  // --- Giữ nguyên các hàm: _retryRequest, _handleTokenRefresh, _saveTokens ---
  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );
    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  Future<bool> _handleTokenRefresh() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post('/refresh', data: {'refreshToken': refreshToken});
      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = UserToken.fromJson(response.data);
        await _saveTokens(token);
        return true;
      }
    } catch (_) {}
    await logout();
    return false;
  }

  Future<void> _saveTokens(UserToken token) async {
    await _storage.write(key: 'accessToken', value: token.accessToken);
    await _storage.write(key: 'refreshToken', value: token.refreshToken);
  }

  // --- Giữ nguyên hàm login bằng email/password ---
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
      throw Exception(e.response?.data['message'] ?? 'Đăng nhập thất bại');
    }
  }

  // --- THÊM MỚI: Hàm đăng nhập bằng Firebase ID Token ---
  // Backend của bạn cần có một endpoint (ví dụ: /auth/firebase-login)
  // để nhận idToken, xác thực nó, và trả về token của hệ thống bạn.
  Future<Map<String, dynamic>?> getFirebaseProfile(String idToken) async {
    try {
      final response = await _dio.get(
        '/profile',
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'},
        ),
      );
      return response.data;
    } on DioException catch (e) {
      print("Lỗi khi gọi API profile: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? 'Không thể lấy profile');
    }
  }



  Future<UserToken?> tryAutoLogin() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) return null;
    try {
      final response = await _dio.post('/refresh', data: {'refreshToken': refreshToken});
      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = UserToken.fromJson(response.data);
        await _saveTokens(token);
        return token;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    // Thêm đăng xuất khỏi Firebase nếu cần, nhưng thường ViewModel sẽ gọi riêng
  }
}