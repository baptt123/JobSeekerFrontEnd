// services/conversation_service.dart (TẠO FILE MỚI)

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/conversation-user-entity.dart';
import '../utils/constant_api.dart';

class ConversationService {
  final Dio _dio = Dio(BaseOptions(baseUrl: ConstantAPI.baseUrl));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  ConversationService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Gắn token vào header cho API /users/conversations
        final accessToken = await _storage.read(key: 'accessToken');
        if (accessToken != null) {
          options.headers['Authorization'] = 'Bearer $accessToken';
        }
        handler.next(options);
      },
      onError: (error, handler) async {
        // Bạn có thể thêm logic refresh token ở đây nếu muốn
        handler.next(error);
      },
    ));
  }

  // Hàm gọi API
  Future<List<ConversationUserEntity>> getConversationList() async {
    try {
      final response = await _dio.get('/user/conversations'); // Tên API mới

      if (response.statusCode == 200) {
        List<dynamic> data = response.data as List;
        return data.map((json) => ConversationUserEntity.fromJson(json)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi lấy danh sách chat');
    }
  }
}