import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../dto/change_password_dto.dart';

class ChangePasswordService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://192.168.67.109:3000/auth', // <<< THAY ĐỔI URL CỦA BẠN
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );


  Future<String> updatePassword(ChangePasswordDto dto) async {
    try {
      // TODO: Lấy token đã lưu của người dùng (ví dụ từ SharedPreferences hoặc FlutterSecureStorage)
      // final String? authToken = await const FlutterSecureStorage().read(key: 'accessToken');
      final String? authToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOjEwMDEsImVtYWlsIjoibmdvdGhhbmh0YW5AdGVzdDEyMy5jb20iLCJyb2xlIjoiQ0FORElEQVRFIiwiaWF0IjoxNzYwOTM0Mzk5LCJleHAiOjE3NjA5MzYxOTl9.XRbyJYPfQWU8VYszGJBgao2YuY2c-F9Ut6hjieFRQvE';
      if (authToken == null) {
        throw Exception("Người dùng hiện tại không đuọc xác thực.");
      }

      final response = await _dio.put(
        '/update-password',
        data: dto.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $authToken',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        // Backend của bạn trả về { message: '...' }
        return response.data['message'] ?? 'Cập nhật mật khẩu thành công';
      } else {
        throw 'Lỗi không xác định. Vui lòng thử lại.';
      }
    } on DioException catch (e) {
      // THAY THẾ TOÀN BỘ KHỐI NÀY
      if (e.response != null && e.response?.data != null) {
        final errorData = e.response!.data;

        // Trường hợp 1: errorData là một Map (phổ biến nhất)
        if (errorData is Map<String, dynamic>) {
          final message = errorData['message'];
          if (message is String) {
            throw message; // message là một chuỗi: "Mật khẩu cũ không đúng"
          }
          if (message is List) {
            throw message.join(', '); // message là một list: ["Lỗi 1", "Lỗi 2"]
          }
        }

        // Trường hợp 2: errorData là một List
        if (errorData is List) {
          throw errorData.join(', ');
        }

        // Trường hợp 3: Các loại lỗi khác
        throw errorData.toString();
      }

      // Lỗi mạng hoặc các lỗi không có response body
      throw 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng.';
    } catch (e) {
      throw e.toString();
    }
  }
}
