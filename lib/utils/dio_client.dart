import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constant_api.dart';

class DioClient {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // URL dùng để refresh token
  static const String _authUrl = '${ConstantAPI.baseUrl}/auth';

  /// Hàm trả về một instance Dio đã được cấu hình sẵn Interceptor
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
        // 1. Tự động gắn Token vào Header
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        // 2. Tự động xử lý lỗi 401 (Token hết hạn)
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            print("⚠️ Token hết hạn (401). Đang thử Refresh...");

            // Gọi hàm refresh token
            final isRefreshed = await _handleTokenRefresh();

            if (isRefreshed) {
              print("✅ Refresh thành công. Đang gọi lại API cũ...");
              // Lấy token mới
              final newToken = await _storage.read(key: 'accessToken');

              // Cập nhật token mới vào request cũ
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';

              // Tạo một instance Dio mới (hoặc dùng cái cũ) để gọi lại request
              // Lưu ý: Dùng Dio() mới để tránh lặp interceptor vô hạn nếu config sai
              final retryDio = Dio();

              try {
                final response = await retryDio.request(
                  '${error.requestOptions.baseUrl}${error.requestOptions.path}',
                  data: error.requestOptions.data,
                  queryParameters: error.requestOptions.queryParameters,
                  options: Options(
                    method: error.requestOptions.method,
                    headers: error.requestOptions.headers,
                  ),
                );
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            } else {
              print("❌ Refresh thất bại. Yêu cầu đăng nhập lại.");
            }
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Hàm gọi API Refresh Token
  static Future<bool> _handleTokenRefresh() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) return false;

    try {
      // Dùng Dio riêng để không bị dính Interceptor của chính nó
      final dio = Dio();
      final response = await dio.post(
        '$_authUrl/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        await _storage.write(key: 'accessToken', value: data['accessToken']);
        await _storage.write(key: 'refreshToken', value: data['refreshToken']);
        return true;
      }
    } catch (e) {
      print("Lỗi khi gọi API Refresh: $e");
      // Nếu refresh lỗi -> Xóa token để app tự logout
      await _storage.deleteAll();
    }
    return false;
  }
}