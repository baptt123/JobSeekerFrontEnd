// lib/utils/dio_client.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constant_api.dart';

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

            // Gọi refresh
            final isRefreshed = await _handleTokenRefresh();

            if (isRefreshed) {
              print("✅ Refresh thành công. Đang gọi lại API cũ...");

              final newToken = await _storage.read(key: 'accessToken');

              // Tạo Dio mới để retry
              final retryDio = Dio();

              // Cập nhật header Authorization với token MỚI
              final newHeaders = Map<String, dynamic>.from(error.requestOptions.headers);
              newHeaders['Authorization'] = 'Bearer $newToken';

              // ✅ XỬ LÝ URL CHUẨN XÁC:
              // Nếu path chưa có http (là đường dẫn tương đối), cần nối với baseUrl cũ
              String requestUrl = error.requestOptions.path;
              if (!requestUrl.startsWith('http')) {
                requestUrl = (error.requestOptions.baseUrl) + requestUrl;
              }

              print("🔄 Retrying request to: $requestUrl");

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
                print("❌ Retry thất bại: $e");
                // Nếu retry vẫn lỗi -> Trả về lỗi gốc để App logout
                return handler.next(error);
              }
            } else {
              print("❌ Refresh thất bại. Yêu cầu đăng nhập lại.");
              await _storage.deleteAll();
            }
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  static Future<bool> _handleTokenRefresh() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) return false;

    try {
      final dio = Dio();
      // Gọi refresh
      final response = await dio.post(
        '$_authUrl/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        // Kiểm tra kỹ dữ liệu trả về trước khi lưu
        if (data['accessToken'] != null) {
          await _storage.write(key: 'accessToken', value: data['accessToken']);
        }
        if (data['refreshToken'] != null) {
          await _storage.write(key: 'refreshToken', value: data['refreshToken']);
        }
        return true;
      }
    } catch (e) {
      print("Lỗi Refresh Token API: $e");
      await _storage.deleteAll();
    }
    return false;
  }
}