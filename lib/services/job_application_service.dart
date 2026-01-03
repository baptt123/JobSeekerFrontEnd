import 'package:dio/dio.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class JobApplicationService {
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/job-application');

  // [UPDATE] Nhận thêm cvId và coverLetter
  Future<void> applyForJob({
    required int jobId,
    int? cvId,
    String? coverLetter
  }) async {
    try {
      final data = {
        'jobId': jobId,
        if (cvId != null) 'cvId': cvId,
        if (coverLetter != null && coverLetter.isNotEmpty) 'coverLetter': coverLetter,
      };

      await _dio.post('/apply', data: data);
    } on DioException catch (e) {
      // Trả về lỗi chi tiết từ backend để hiển thị
      throw Exception(e.response?.data['message'] ?? 'Lỗi ứng tuyển');
    }
  }

  // [NEW] Hàm hủy ứng tuyển
  Future<void> cancelApplication(int jobId) async {
    try {
      // Gọi method PATCH /cancel/:jobId
      await _dio.patch('/cancel/$jobId');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi hủy ứng tuyển');
    }
  }

  Future<bool> checkApplicationStatus(int jobId) async {
    try {
      await _dio.get('/status', queryParameters: {'jobId': jobId});
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return false;
      return false;
    }
  }
}