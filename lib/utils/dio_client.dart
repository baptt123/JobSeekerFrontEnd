// lib/utils/dio_client.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'constant_api.dart';
import 'global_keys.dart';

class DioClient {
  static final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _authUrl = '${ConstantAPI.baseUrl}/auth';

  static bool _isRefreshing = false;

  static Dio getDio({String? baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? ConstantAPI.baseUrl,
        connectTimeout: const Duration(seconds: 120),
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 120),
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
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {

            // 🔥 [CHỐT CHẶN QUAN TRỌNG] Kiểm tra xem có refresh token không
            final refreshToken = await _storage.read(key: 'refreshToken');

            // Nếu không có refresh token -> Nghĩa là đang là GUEST hoặc đã Logout.
            // Mà Guest gặp 401 nghĩa là API đó bắt buộc đăng nhập nhưng lại gọi khi chưa đăng nhập.
            // -> CHẶN NGAY: Trả về data rỗng để không crash, và KHÔNG refresh/redirect nữa.
            if (refreshToken == null) {
              print("⚠️ Guest gặp lỗi 401 (API yêu cầu Auth). Bỏ qua để tránh lặp.");
              return handler.resolve(Response(
                requestOptions: error.requestOptions,
                statusCode: 200, // Fake thành công
                data: {},        // Data rỗng
              ));
            }

            // --- Logic Refresh Token bình thường (Chỉ chạy khi CÓ refreshToken) ---
            if (_isRefreshing) {
              return handler.resolve(Response(requestOptions: error.requestOptions, statusCode: 200, data: {}));
            }

            print("⚠️ Token hết hạn (401). Đang thử Refresh...");
            _isRefreshing = true;

            try {
              final isRefreshed = await _handleTokenRefresh();
              _isRefreshing = false;

              if (isRefreshed) {
                print("✅ Refresh thành công. Retry...");
                final newToken = await _storage.read(key: 'accessToken');
                final retryDio = Dio();
                final newHeaders = Map<String, dynamic>.from(error.requestOptions.headers);
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
                    options: Options(method: error.requestOptions.method, headers: newHeaders),
                  );
                  return handler.resolve(response);
                } catch (e) {
                  await _switchToGuestMode();
                  return handler.resolve(Response(requestOptions: error.requestOptions, statusCode: 200, data: {}));
                }
              } else {
                print("❌ Refresh thất bại -> Chuyển sang Guest Mode.");
                await _switchToGuestMode();
                return handler.resolve(Response(requestOptions: error.requestOptions, statusCode: 200, data: {}));
              }
            } catch (e) {
              _isRefreshing = false;
              await _switchToGuestMode();
              return handler.resolve(Response(requestOptions: error.requestOptions, statusCode: 200, data: {}));
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
      final response = await dio.post('$_authUrl/refresh', data: {'refreshToken': refreshToken});

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['accessToken'] != null) await _storage.write(key: 'accessToken', value: data['accessToken']);
        if (data['refreshToken'] != null) await _storage.write(key: 'refreshToken', value: data['refreshToken']);
        return true;
      }
    } catch (e) {
      print("Lỗi Refresh: $e");
    }
    return false;
  }

  static Future<void> _switchToGuestMode() async {
    await _storage.deleteAll();
    ManagingGlobalKey.navigatorKey.currentState?.pushNamedAndRemoveUntil('/home', (route) => false);
  }
}