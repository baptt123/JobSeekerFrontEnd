import 'package:dio/dio.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class JobApplicationService {
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/job-application');

  Future<void> applyForJob(int jobId) async {
    try {
      await _dio.post('/apply', data: {'jobId': jobId});
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ?? 'Lỗi ứng tuyển');
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