// lib/services/conversation_service.dart
import 'package:dio/dio.dart';
import '../models/conversation-user-entity.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class ConversationService {
  // Sử dụng DioClient để tự động gắn Token
  final Dio _dio = DioClient.getDio(baseUrl: ConstantAPI.baseUrl);

  Future<List<ConversationUserEntity>> getConversationList() async {
    try {
      // Gọi API mới: /message/partners
      final response = await _dio.get('/message/partners');

      // Map dữ liệu trả về
      if (response.data is List) {
        return (response.data as List)
            .map((json) => ConversationUserEntity.fromJson(json))
            .toList();
      }
      return [];
    } catch (e) {
      // Nếu lỗi 401 thì DioClient đã xử lý hoặc throw ra ngoài để ViewModel bắt
      throw Exception('Lỗi tải danh sách chat: $e');
    }
  }
}