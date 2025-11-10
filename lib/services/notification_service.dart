// // lib/services/notification_api_service.dart
//
// import 'package:dio/dio.dart';
// import 'package:job_seeker_frontend/utils/constant_api.dart';
//
// import '../models/notification-entity.dart'; // Giả sử bạn có file này
//
// class NotificationService {
//   final Dio _dio = Dio();
//
//   // Giả sử BASE_URL = "http://your_ip:3000/api"
//   final String _apiUrl = "${ConstantAPI.baseUrl}/firebase/send-test";
//
//   // Hàm gọi API để test gửi thông báo
//   Future<bool> sendTestNotification({
//     required String token,
//     required String title,
//     required String body,
//     int? userId,
//   }) async {
//     try {
//       final response = await _dio.post(
//         _apiUrl,
//         data: {
//           'token': token,
//           'title': title,
//           'body': body,
//           'userId': userId, // Gửi cả userId để backend lưu vào DB [cite: 45]
//         },
//       );
//
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         if (response.data['success'] == true) {
//           print('API call successful: ${response.data['message']}');
//           return true;
//         }
//       }
//       print('API call failed: ${response.data}');
//       return false;
//     } on DioException catch (e) {
//       print('Dio error sending test notification: $e');
//       return false;
//     } catch (e) {
//       print('Unknown error sending test notification: $e');
//       return false;
//     }
//   }
//   Future<List<NotificationEntity>> getNotificationsByUserId(int userId) async {
//     try {
//       // Giả sử backend có endpoint: /api/notifications/:userId
//       final response = await _dio.get("$_apiUrl/$userId");
//
//       if (response.statusCode == 200) {
//         List<dynamic> data = response.data;
//         return data.map((json) => NotificationEntity.fromJson(json)).toList();
//       }
//       return [];
//     } catch (e) {
//       print('Dio error fetching notifications: $e');
//       return [];
//     }
//   }
// }

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/notification-entity.dart';
import '../utils/constant_api.dart';

class NotificationService {
  final Dio _dio = Dio(BaseOptions(baseUrl: '${ConstantAPI.baseUrl}/firebase'));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  NotificationService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
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
              final retryResponse = await _retryRequest(error.requestOptions);
              return handler.resolve(retryResponse);
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  /// --- Hàm retry lại request sau khi refresh token ---
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

  /// --- Hàm refresh token khi accessToken hết hạn ---
  Future<bool> _handleTokenRefresh() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) return false;

    try {
      final response = await _dio.post(
        '${ConstantAPI.baseUrl}/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        await _storage.write(key: 'accessToken', value: data['accessToken']);
        await _storage.write(key: 'refreshToken', value: data['refreshToken']);
        return true;
      }
    } catch (_) {}
    await logout();
    return false;
  }

  /// --- Đăng xuất, xoá token ---
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  /// --- Gửi thông báo test ---
  Future<bool> sendTestNotification({
    required String token,
    required String title,
    required String body,
    int? userId,
  }) async {
    try {
      final response = await _dio.post(
        '/send-test',
        data: {'token': token, 'title': title, 'body': body, 'userId': userId},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (response.data['success'] == true) {
          print('Gửi thông báo thành công: ${response.data['message']}');
          return true;
        }
      }
      print('Gửi thông báo thất bại: ${response.data}');
      return false;
    } on DioException catch (e) {
      print('Dio error khi gửi thông báo: $e');
      return false;
    } catch (e) {
      print('Lỗi không xác định khi gửi thông báo: $e');
      return false;
    }
  }

  /// --- Lấy danh sách thông báo của user ---
  Future<List<NotificationEntity>> getNotificationsByUserId(int userId) async {
    try {
      final response = await _dio.get('/notifications/$userId');

      if (response.statusCode == 200) {
        final data = response.data;

        // Vì backend trả { success: true, data: [...] }
        final List<dynamic> list = (data['data'] ?? []) as List<dynamic>;

        return list.map((json) => NotificationEntity.fromJson(json)).toList();
      } else {
        print('Unexpected status code: ${response.statusCode}');
        return [];
      }
    } on DioException catch (e) {
      print('Dio error fetching notifications: $e');
      return [];
    } catch (e) {
      print('Unknown error fetching notifications: $e');
      return [];
    }
  }
}
