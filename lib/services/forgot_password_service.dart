// services/auth_service.dart

import 'package:dio/dio.dart';

import '../dto/forgot_password_dto.dart';

class ForgotPasswordService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'http://192.168.67.109:3000/auth', // <-- THAY ĐỔI URL API CỦA BẠN
  ));

  // 2. Thay đổi tham số từ String thành ForgotPasswordDto
  Future<String> forgotPassword(ForgotPasswordDto dto) async {
    try {
      final response = await _dio.put(
        '/forgot-password',
        data: dto.toJson(), // <-- 3. Sử dụng phương thức toJson() của DTO
      );

      if (response.statusCode == 200 && response.data != null) {
        return response.data['message'] as String;
      } else {
        throw 'Đã xảy ra lỗi không xác định.';
      }
    } on DioException catch (e) {
      if (e.response?.data != null && e.response?.data['message'] != null) {
        throw e.response!.data['message'];
      }
      throw 'Không thể kết nối đến máy chủ. Vui lòng thử lại.';
    } catch (e) {
      throw 'Đã xảy ra lỗi. Vui lòng thử lại.';
    }
  }
}