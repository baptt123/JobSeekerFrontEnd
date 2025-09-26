import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../dto/change_password_dto.dart';
import '../dto/register_dto.dart';
import '../models/user-entity.dart';
import '../utils/token_storage.dart';

class AuthService {
  static final baseUrl = "${dotenv.env['API_URL']}/auth";
  static const accessTokenKey = 'accessToken';
  static const refreshTokenKey = 'refreshToken';

  static final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final res = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (res.statusCode == 200) {
        final data = res.data as Map<String, dynamic>;
        await TokenStorage.saveTokens(
          data[accessTokenKey],
          data[refreshTokenKey],
        );
        return data;
      } else {
        throw Exception(res.data['message'] ?? 'Login failed');
      }
    } on DioError catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Login failed');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<UserEntity?> register(RegisterDto dto) async {
    try {
      final res = await _dio.post(
        '/register',
        data: dto.toJson(),
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        final data = res.data as Map<String, dynamic>;
        return UserEntity.fromJson(data['user']);
      } else {
        throw Exception(res.data['message'] ?? 'Đăng ký thất bại');
      }
    } on DioError catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Đăng ký thất bại');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  static Future<void> logout() async {
    await TokenStorage.clearTokens();
  }
  Future<void> updatePassword(ChangePasswordDTO dto) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      throw Exception("Bạn chưa đăng nhập");
    }

    try {
      final res = await _dio.post(
        '/update-password',
        data: dto.toJson(),
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        }),
      );

      if (res.statusCode == 200) {
        // clear token local khi đổi mật khẩu thành công
        await TokenStorage.clearTokens();
      } else {
        throw Exception(res.data['message'] ?? 'Đổi mật khẩu thất bại');
      }
    } on DioError catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Đổi mật khẩu thất bại');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      final res = await _dio.post(
        '/forgot-password',
        data: {"email": email},
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );

      if (res.statusCode == 200) {
        // clear token local nếu có
        await TokenStorage.clearTokens();
      } else {
        throw Exception(res.data['message'] ?? 'Lỗi reset mật khẩu');
      }
    } on DioError catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Lỗi reset mật khẩu');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
