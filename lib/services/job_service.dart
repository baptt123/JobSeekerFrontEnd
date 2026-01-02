import 'package:dio/dio.dart';
import '../dto/filter_job_dto.dart';
import '../dto/pagination_job_response_dto.dart';
import '../models/job-entity.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class JobService {
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/job');

  Future<PaginatedJobsResponse> getAllJobs({int page = 1, int limit = 10}) async {
    final response = await _dio.get('/get-all-jobs', queryParameters: {'page': page, 'limit': limit});
    return PaginatedJobsResponse.fromJson(response.data);
  }

  Future<JobEntity> getJobDetail(String title) async {
    final encodedTitle = Uri.encodeComponent(title);
    final response = await _dio.get('/detail/$encodedTitle'); // Tự động kèm token nếu có
    if (response.data != null) return JobEntity.fromJson(response.data);
    throw Exception('Data null');
  }

  Future<List<JobEntity>> getRecommendedJobs() async {
    try {
      final response = await _dio.get('/recommended');
      if (response.data is List) {
        return (response.data as List).map((json) => JobEntity.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<void> saveJob(int jobId) async {
    await _dio.post('/create-save-job', data: {'job_id': jobId});
  }

  Future<void> unsaveJob(int jobId) async {
    await _dio.delete('/delete-job/$jobId');
  }

  Future<List<JobEntity>> getSavedJobs() async {
    final response = await _dio.get('/get-my-saved-jobs');
    return (response.data as List).map((json) => JobEntity.fromJson(json)).toList();
  }

  Future<List<JobEntity>> filterJobs(FilterJobDto dto) async {
    final response = await _dio.get('/filter', queryParameters: dto.toQueryParameters());
    return (response.data as List).map((json) => JobEntity.fromJson(json)).toList();
  }

  Future<List<JobEntity>> searchJobs(String query, {int size = 10}) async {
    final response = await _dio.get('/search-jobs', queryParameters: {'query': query, 'size': size});
    return (response.data as List).map((json) => JobEntity.fromJson(json)).toList();
  }

  Future<List<String>> suggestJobs(String query) async {
    if (query.isEmpty) return [];
    final response = await _dio.get('/suggest', queryParameters: {'q': query});
    return List<String>.from(response.data);
  }
  // [THÊM MỚI] Lấy thông tin công ty và list jobs
  Future<Map<String, dynamic>> getCompanyWithJobs(int companyId) async {
    try {
      final response = await _dio.get('/company/$companyId/jobs');
      return response.data['data'] ?? {};
    } catch (e) {
      throw Exception('Lỗi lấy thông tin công ty: $e');
    }
  }
  // [THÊM MỚI] Lấy danh sách random jobs cho banner
  Future<List<JobEntity>> getRandomJobs() async {
    try {
      final response = await _dio.get('/random');
      final data = response.data['data'];
      if (data is List) {
        return data.map((json) => JobEntity.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Lỗi khi lấy các job ngẫu nhiên: $e');
      return []; // Trả về list rỗng nếu lỗi
    }
  }
}