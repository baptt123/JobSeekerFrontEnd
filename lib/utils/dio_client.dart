// lib/utils/dio_client.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart'; // Import để dùng Navigator
import 'constant_api.dart';
import 'global_keys.dart'; // ✅ Import Key

class DioClient {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _authUrl = '${ConstantAPI.baseUrl}/auth';

  static Dio getDio({String? baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ConstantAPI.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            print("⚠️ Token hết hạn (401). Đang thử Refresh...");

            final isRefreshed = await _handleTokenRefresh();

            if (isRefreshed) {
              // ... (Logic retry giữ nguyên) ...
              // (Phần code retry request cũ của bạn ở đây)

              // Ví dụ ngắn gọn cho phần retry:
              final newToken = await _storage.read(key: 'accessToken');
              final retryDio = Dio();
              final newHeaders = Map<String, dynamic>.from(
                error.requestOptions.headers,
              );
              newHeaders['Authorization'] = 'Bearer $newToken';

              String requestUrl = error.requestOptions.path;
              if (!requestUrl.startsWith('http')) {
                requestUrl = (error.requestOptions.baseUrl) + requestUrl;
              }

              try {
                final response = await retryDio.request(
                  requestUrl,
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                  options: Options(
                    method: error.requestOptions.method,
                    headers: newHeaders,
                  ),
                );
                return handler.resolve(response);
              } catch (e) {
                // Nếu Retry vẫn lỗi -> Logout
                await _performLogout();
                return handler.next(error);
              }
            } else {
              print("❌ Refresh thất bại. Yêu cầu đăng nhập lại.");
              // ✅ GỌI HÀM LOGOUT & ĐIỀU HƯỚNG
              await _performLogout();
            }
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  // --- Hàm xử lý Refresh Token (Giữ nguyên logic cũ) ---
  static Future<bool> _handleTokenRefresh() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) return false;

    try {
      // Dùng Dio mới để tránh interceptor lặp vô tận
      final dio = Dio();
      final response = await dio.post(
        '$_authUrl/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['accessToken'] != null) {
          await _storage.write(key: 'accessToken', value: data['accessToken']);
        }
        if (data['refreshToken'] != null) {
          await _storage.write(
            key: 'refreshToken',
            value: data['refreshToken'],
          );
        }
        return true;
      }
    } catch (e) {
      print("Lỗi Refresh Token API: $e");
    }
    return false;
  }

  // --- ✅ HÀM MỚI: Xóa token và Điều hướng về Login ---
  static Future<void> _performLogout() async {
    await _storage.deleteAll(); // Xóa sạch token

    // Sử dụng Global Key để điều hướng mà không cần BuildContext
    ManagingGlobalKey.navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/login',
      (route) => false, // Xóa hết lịch sử các màn hình trước đó
    );
  }
}
