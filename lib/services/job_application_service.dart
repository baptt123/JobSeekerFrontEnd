import 'package:dio/dio.dart';

import '../utils/constant_api.dart';
class JobApplicationService{
  final Dio _dio = Dio(BaseOptions(baseUrl: ConstantAPI.baseUrl+'/job-application'));
  // ⭐️ HÀM MỚI ĐỂ ỨNG TUYỂN
  Future<void> applyForJob(int jobId) async {
    // "userId ở đây tôi đang dùng mặc định là 1 để test á"
    // const int testUserId = 1;

    try {
      // Giả sử endpoint của bạn là /apply (sẽ thành /job/apply)
      await _dio.post(
        '/apply',
        data: {
          'jobId': jobId,
          // 'user_id': testUserId, // Gửi User ID cứng = 1 để test
        },
      );
    } on DioException catch (e) {
      // Xử lý lỗi cụ thể từ backend (ví dụ: 400, 409, 404)
      if (e.response != null) {
        // Backend sẽ trả về lỗi dạng { "message": "Lỗi..." }
        final errorMessage = e.response?.data?['message'] ?? 'Lỗi không xác định';

        // "nếu rồi thì làm sao đó" -> Backend trả về lỗi (ví dụ: "Bạn đã ứng tuyển...")
        // "còn hạn" -> Backend trả về lỗi (ví dụ: "Công việc đã hết hạn...")

        // Ném lỗi này để ViewModel có thể bắt và hiển thị
        throw Exception(errorMessage);
      } else {
        // Lỗi mạng, timeout...
        print('Lỗi mạng [applyForJob]: $e');
        throw Exception('Lỗi kết nối: ${e.message}');
      }
    } catch (e) {
      print('Lỗi lạ [applyForJob]: $e');
      throw Exception('Đã xảy ra lỗi không mong muốn');
    }
  }
  // --- ⭐️ HÀM MỚI ĐỂ KIỂM TRA TRẠNG THÁI ⭐️ ---
  /// Kiểm tra xem người dùng đã ứng tuyển công việc này chưa.
  /// Backend NestJS đang hardcode userId = 1
  Future<bool> checkApplicationStatus(int jobId) async {
    // const int testUserId = 1;

    try {
      await _dio.get(
        '/status', // Endpoint mới
        queryParameters: {
          'jobId': jobId,
          // 'userId': testUserId, // Backend NestJS đang hardcode 1
        },
      );

      // Nếu request thành công (200 OK), nghĩa là đã ứng tuyển
      return true;

    } on DioException catch (e) {
      // Nếu 404 Not Found, nghĩa là backend không tìm thấy -> CHƯA ứng tuyển
      if (e.response?.statusCode == 404) {
        return false;
      }

      // Các lỗi khác (500, 400...)
      if (e.response != null) {
        final errorMessage =
            e.response?.data?['message'] ?? 'Lỗi khi kiểm tra trạng thái';
        throw Exception(errorMessage);
      } else {
        // Lỗi mạng, timeout...
        print('Lỗi mạng [checkStatus]: $e');
        throw Exception('Lỗi kết nối: ${e.message}');
      }
    } catch (e) {
      print('Lỗi lạ [checkStatus]: $e');
      throw Exception('Đã xảy ra lỗi không mong muốn');
    }
  }
}