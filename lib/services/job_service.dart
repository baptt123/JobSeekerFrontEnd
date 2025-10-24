// lib/services/job_service.dart

import 'package:dio/dio.dart';

import '../dto/pagination_job_response_dto.dart';
import '../models/job-entity.dart';
import '../utils/constant_api.dart';

class JobService {
  // Thay thế 'YOUR_BASE_API_URL' bằng URL backend của bạn
  // Ví dụ: 'http://10.0.2.2:3000/api' (cho Android emulator)
  final Dio _dio = Dio(BaseOptions(
    baseUrl: ConstantAPI.baseUrl+'/job',
  ));

  Future<PaginatedJobsResponse> getAllJobs({int page = 1, int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/get-all-jobs',
        queryParameters: {'page': page, 'limit': limit},
      );

      // Giả sử response.data là Map<String, dynamic>
      // đã được dio parse từ JSON
      return PaginatedJobsResponse.fromJson(response.data);
    } on DioException catch (e) {
      // Xử lý lỗi, có thể log hoặc throw một lỗi cụ thể hơn
      print('Error fetching jobs: $e');
      rethrow;
    }
  }
  /// Gọi API /search-jobs
  Future<List<JobEntity>> searchJobs(String query, {int size = 10}) async {
    try {
      final response = await _dio.get(
        '/search-jobs',
        queryParameters: {
          'query': query,
          'size': size,
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        // response.data là một List<dynamic> (List<Map<String, dynamic>>)
        final List<dynamic> results = response.data;
        return results.map((json) => JobEntity.fromJson(json)).toList();
      } else {
        throw Exception('Không thể tải dữ liệu tìm kiếm');
      }
    } on DioException catch (e) {
      // Xử lý lỗi Dio
      print('Lỗi Dio[searchJobs]: $e');
      throw Exception('Lỗi mạng: ${e.message}');
    } catch (e) {
      print('Lỗi [searchJobs]: $e');
      throw Exception('Đã xảy ra lỗi không mong muốn');
    }
  }

  /// Gọi API /suggest
  Future<List<String>> suggestJobs(String query) async {
    if (query.isEmpty) {
      return [];
    }
    try {
      final response = await _dio.get(
        '/suggest',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200 && response.data is List) {
        // Backend trả về List<string>
        return List<String>.from(response.data);
      } else {
        throw Exception('Không thể tải gợi ý');
      }
    } on DioException catch (e) {
      // Bỏ qua lỗi (ví dụ: gõ quá nhanh) để không làm phiền người dùng
      print('Lỗi Dio[suggestJobs]: $e');
      return []; // Trả về list rỗng khi có lỗi
    } catch (e) {
      print('Lỗi [suggestJobs]: $e');
      return []; // Trả về list rỗng khi có lỗi
    }
  }
}