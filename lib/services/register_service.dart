// lib/services/auth_service.dart

import 'package:dio/dio.dart';
import 'package:job_seeker_frontend/dto/register_dto.dart';

class RegisterService {
  final Dio _dio = Dio(
    BaseOptions(
      // ⚠️ THAY ĐỔI URL NÀY THÀNH ĐỊA CHỈ API CỦA BẠN
      baseUrl: 'http://192.168.67.109:3000/auth', // Dùng 10.0.2.2 cho Android Emulator
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  Future<Response> register(RegisterDTO registerData) async {
    try {
      final response = await _dio.post(
        '/register', // Giả sử endpoint của bạn là /auth/register
        data: registerData.toJson(),
      );
      return response;
    } on DioException catch (e) {
      // Ném lại lỗi để ViewModel có thể bắt và xử lý
      throw e;
    }
  }
}