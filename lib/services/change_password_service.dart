import 'package:dio/dio.dart';
import '../dto/change_password_dto.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class ChangePasswordService {
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/auth');

  Future<String> updatePassword(ChangePasswordDto dto) async {
    try {
      // Không cần truyền header Token thủ công nữa
      final response = await _dio.put('/update-password', data: dto.toJson());
      return response.data['message'] ?? 'Thành công';
    } on DioException catch (e) {
      throw e.response?.data['message'] ?? 'Lỗi đổi mật khẩu';
    }
  }
}