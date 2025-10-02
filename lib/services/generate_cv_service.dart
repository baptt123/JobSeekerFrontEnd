import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../dto/create_user_cv_dto.dart';
import '../models/user-cv-entity.dart';

class GenerativeCVService {
  static final baseUrl = "${dotenv.env['API_URL']}/cv";
  static final Dio _dio = Dio(BaseOptions(baseUrl: baseUrl));

  static Future<Uint8List> generateCV(String prompt) async {
    try {
      final res = await _dio.post(
        '/generate',
        data: {'prompt': prompt},
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );

      if (res.statusCode == 200) {
        return Uint8List.fromList(res.data is List<int>
            ? List<int>.from(res.data)
            : res.data.toString().codeUnits);
      } else {
        throw Exception(res.data['message'] ?? 'Generate CV failed');
      }
    } on DioError catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Generate CV failed');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  static Future<UserCVEntity> createCvWithKeywords(
      CreateUserCvDto dto) async {
    try {
      final res = await _dio.post(
        '/create-with-keywords',
        data: dto.toJson(),
        options: Options(headers: {
          'Content-Type': 'application/json',
        }),
      );

      if (res.statusCode == 200 || res.statusCode == 201) {
        return UserCVEntity.fromJson(res.data);
      } else {
        throw Exception(res.data['message'] ?? 'Create CV failed');
      }
    } on DioError catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ?? 'Create CV failed');
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }
}
