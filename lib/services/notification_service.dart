// lib/services/notification_service.dart
import 'package:dio/dio.dart';
import '../models/notification-entity.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class NotificationService {
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/firebase');

  // [UPDATE] Không cần truyền userId, Backend tự lấy từ Token
  Future<List<NotificationEntity>> getNotifications() async {
    try {
      final response = await _dio.get('/notifications');
      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((json) => NotificationEntity.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      print("Error fetching notifications: $e");
      return [];
    }
  }


}