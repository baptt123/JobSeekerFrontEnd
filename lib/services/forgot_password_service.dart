import 'package:dio/dio.dart';
import '../dto/forgot_password_dto.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class ForgotPasswordService {
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/auth');

  Future<String> forgotPassword(ForgotPasswordDto dto) async {
    try {
      final response = await _dio.put('/forgot-password', data: dto.toJson());
      return response.data['message'] ?? 'Thành công';
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Lỗi gửi yêu cầu';
    }
  }
}