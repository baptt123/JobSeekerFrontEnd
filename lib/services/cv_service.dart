// lib/services/cv_service.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../dto/create_cv_dto.dart';
import '../models/user-cv-entity.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class CvGenerationService {
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/cv');

  // --- 1. Tạo CV bằng AI (Prompt) ---
  Future<Uint8List> generateCv(String prompt) async {
    try {
      final response = await _dio.post(
        '/gen-cv',
        data: {'prompt': prompt},
        options: Options(
          responseType: ResponseType.bytes,
          receiveTimeout: const Duration(seconds: 60),
        ),
      );
      return Uint8List.fromList(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.statusMessage ?? 'Lỗi kết nối hoặc tạo CV');
    }
  }

  Future<void> uploadCv(File file, String title) async {
    try {
      String fileName = file.path.split('/').last;
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: fileName),
        'title': title,
      });
      await _dio.post('/upload', data: formData);
    } catch (e) {
      throw Exception('Lỗi upload CV: $e');
    }
  }

  // Preview CV (Trả về file PDF dưới dạng bytes)
  Future<Uint8List> previewCvPdf(String templateId, CreateCvDto cvData) async {
    try {
      final response = await _dio.post(
        '/preview/$templateId',
        data: cvData.toJson(),
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data);
    } on DioException catch (e) {
      throw Exception('Lỗi tạo bản xem trước: ${e.message}');
    }
  }

  // Lưu CV
  Future<void> saveGeneratedCv(String templateId, CreateCvDto cvData) async {
    try {
      await _dio.post('/save-generated/$templateId', data: cvData.toJson());
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi khi lưu CV');
    }
  }

  // Lấy danh sách CV
  Future<List<UserCVEntity>> getMyCvs() async {
    final response = await _dio.get('/my-cvs');
    return (response.data['data'] as List)
        .map((json) => UserCVEntity.fromJson(json))
        .toList();
  }

  // Các hàm khác giữ nguyên (setDefaultCv, deleteCv...)
  Future<void> setDefaultCv(int cvId) async =>
      await _dio.patch('/$cvId/set-default');

  Future<void> deleteCv(int cvId) async => await _dio.delete('/$cvId');
}
