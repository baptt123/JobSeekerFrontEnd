// services/job_service.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:job_seeker_frontend/models/job-entity.dart';
import '../utils/token_storage.dart';
import 'package:dio/dio.dart';

class JobService {
  // static const baseUrl = 'http://localhost:3000/jobs';
  static final baseUrl = "${dotenv.env['API_URL']}/search";
  static final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));

  static Future<List<JobEntity>> fetchRecommendedJobs() async {
    final token = await TokenStorage.getAccessToken();
    final res = await http.get(
      Uri.parse('$baseUrl/recommended'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((j) => JobEntity.fromJson(j)).toList();
    } else {
      throw Exception('Failed to load jobs');
    }
  }

  static Future<List<dynamic>> searchJobs(String query) async {
    try {
      final res = await _dio.get(
        '/jobs',
        queryParameters: {'query': query},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (res.statusCode == 200) {
        return res.data as List<dynamic>;
      } else {
        throw Exception(res.data['message'] ?? 'Search failed');
      }
    } on DioError catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Search failed');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  static Future<List<String>> suggestJobs(String query) async {
    try {
      final res = await _dio.get(
        '/suggest',
        queryParameters: {'q': query},
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      if (res.statusCode == 200) {
        return List<String>.from(res.data);
      } else {
        throw Exception(res.data['message'] ?? 'Suggest failed');
      }
    } on DioError catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Suggest failed');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
