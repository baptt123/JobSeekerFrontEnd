import 'package:dio/dio.dart';
import '../models/notification-entity.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class NotificationService {
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/firebase');

  Future<bool> sendTestNotification({required String token, required String title, required String body, int? userId}) async {
    try {
      final response = await _dio.post('/send-test', data: {'token': token, 'title': title, 'body': body, 'userId': userId});
      return response.data['success'] == true;
    } catch (_) { return false; }
  }

  Future<List<NotificationEntity>> getNotificationsByUserId(int userId) async {
    try {
      final response = await _dio.get('/notifications');
      return (response.data['data'] as List).map((json) => NotificationEntity.fromJson(json)).toList();
    } catch (_) { return []; }
  }
}