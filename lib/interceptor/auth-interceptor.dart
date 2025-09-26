import 'package:dio/dio.dart';
import 'package:job_seeker_frontend/utils/token_storage.dart';

import '../services/auth_service.dart';

class AuthInterceptor extends Interceptor {
  final Dio dio;
  final AuthService authService;

  AuthInterceptor(this.dio, this.authService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await TokenStorage.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshToken = await TokenStorage.getRefreshToken();

      if (refreshToken != null) {
        try {
          // Gọi API refresh
          final response = await dio.post('/auth/refresh', data: {
            'refreshToken': refreshToken,
          });

          final newAccessToken = response.data['accessToken'];
          await TokenStorage.saveTokens(newAccessToken, refreshToken);

          // Retry lại request cũ
          final retryRequest = await dio.fetch(err.requestOptions
            ..headers['Authorization'] = 'Bearer $newAccessToken');

          return handler.resolve(retryRequest);
        } catch (e) {
          // Refresh token hết hạn → logout
          await TokenStorage.clearTokens();
          // TODO: điều hướng về màn hình Login
        }
      }
    }
    super.onError(err, handler);
  }
}
