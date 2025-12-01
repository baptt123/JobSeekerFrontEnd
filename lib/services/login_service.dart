import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user-token-entity.dart';
import '../utils/constant_api.dart'; // Giữ nguyên model của bạn

class LoginService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ConstantAPI.baseUrl + '/auth',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  LoginService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Luôn đính kèm AccessToken nếu có
          final accessToken = await _storage.read(key: 'accessToken');
          if (accessToken != null) {
            options.headers['Authorization'] = 'Bearer $accessToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Nếu AccessToken hết hạn (401), thử refresh
          if (error.response?.statusCode == 401) {
            final newAccessToken = await _handleTokenRefresh();
            if (newAccessToken != null) {
              // Update token mới vào header và gọi lại request cũ
              error.requestOptions.headers['Authorization'] =
                  'Bearer $newAccessToken';
              return handler.resolve(await _retryRequest(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

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

  // Helper: Refresh Token ngầm khi đang sử dụng app
  Future<String?> _handleTokenRefresh() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) return null;

    try {
      final response = await _dio.post(
        '/refresh',
        data: {'refreshToken': refreshToken},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final tokenData = UserToken.fromJson(response.data);
        await _saveTokens(tokenData);
        return tokenData.accessToken;
      }
    } catch (_) {
      // Nếu refresh thất bại (hết hạn hẳn), logout
      await logout();
    }
    return null;
  }

  Future<void> _saveTokens(UserToken token) async {
    await _storage.write(key: 'accessToken', value: token.accessToken);
    await _storage.write(key: 'refreshToken', value: token.refreshToken);
    await _storage.write(key: 'userId', value: token.userId.toString());
  }

  // 1. LOGIN (Standard)
  Future<UserToken?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Parse JSON -> UserToken (bao gồm check user object)
        final token = UserToken.fromJson(response.data);
        // Lưu vào Storage
        await _saveTokens(token);
        return token;
      }
      return null;
    } on DioException catch (e) {
      // Ném lỗi rõ ràng để ViewModel hiển thị Toast
      final msg = e.response?.data['message'] ?? 'Đăng nhập thất bại';
      throw Exception(msg);
    }
  }

  // 2. AUTO LOGIN (Chạy khi mở app)
  Future<UserToken?> tryAutoLogin() async {
    // Bước 1: Lấy Refresh Token từ Storage
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) {
      print("Không tìm thấy Refresh Token trong máy.");
      return null;
    }

    try {
      // Bước 2: Gửi lên Server để kiểm tra và lấy token mới
      print("Đang kiểm tra Refresh Token với Server...");
      final response = await _dio.post(
        '/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Bước 3: Nếu hợp lệ, lưu token mới và trả về object User
        final token = UserToken.fromJson(response.data);
        await _saveTokens(token);
        print("Auto Login thành công cho User ID: ${token.userId}");
        return token;
      }
    } catch (e) {
      print("Auto Login thất bại (Token hết hạn hoặc lỗi): $e");
      // Bước 4: Nếu lỗi, xóa sạch token cũ để tránh loop
      await logout();
    }
    return null;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  // --- THÊM MỚI: Hàm đăng nhập bằng Firebase ID Token ---
  // Backend của bạn cần có một endpoint (ví dụ: /auth/firebase-login)
  // để nhận idToken, xác thực nó, và trả về token của hệ thống bạn.
  Future<Map<String, dynamic>?> getFirebaseProfile(String idToken) async {
    try {
      final response = await _dio.get(
        '/profile',
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );
      return response.data;
    } on DioException catch (e) {
      print("Lỗi khi gọi API profile: ${e.response?.data}");
      throw Exception(e.response?.data['message'] ?? 'Không thể lấy profile');
    }
  }
}
