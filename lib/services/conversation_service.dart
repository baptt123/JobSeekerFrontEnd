import 'package:dio/dio.dart';
import '../models/conversation-user-entity.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class ConversationService {
  final Dio _dio = DioClient.getDio(baseUrl: ConstantAPI.baseUrl); // /user/conversations

  Future<List<ConversationUserEntity>> getConversationList() async {
    try {
      final response = await _dio.get('/user/conversations');
      return (response.data as List).map((json) => ConversationUserEntity.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Lỗi tải danh sách chat');
    }
  }
}