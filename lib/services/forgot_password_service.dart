// lib/services/forgot_password_service.dart
import 'package:dio/dio.dart';
import '../dto/forgot_password_dto.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class ForgotPasswordService {
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/auth');

  Future<String> forgotPassword(ForgotPasswordDto dto) async {
    try {
      final response = await _dio.put('/forgot-password', data: dto.toJson());
      // Trả về message thành công từ Backend
      return response.data['message'] ?? 'Mật khẩu mới đã được gửi.';
    } on DioException catch (e) {
      // 🔥 Xử lý lỗi từ Backend trả về (ví dụ: Email không tồn tại)
      if (e.response != null && e.response?.data != null) {
        final errorData = e.response?.data;
        // NestJS thường trả về message dạng String hoặc List<String>
        if (errorData['message'] is List) {
          throw Exception((errorData['message'] as List).join('\n'));
        }
        throw Exception(errorData['message'] ?? 'Lỗi không xác định');
      }
      throw Exception('Lỗi kết nối máy chủ');
    }
  }
}