import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../dto/create_cv_dto.dart';
import '../models/user-cv-entity.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class CvGenerationService {
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/cv');

  Future<Uint8List> generateCv(String prompt) async {
    final response = await _dio.post(
      '/gen-cv',
      data: {'prompt': prompt},
      options: Options(responseType: ResponseType.bytes),
    );
    return response.data as Uint8List;
  }

  Future<String> previewCv(String templateId, CreateCvDto cvData) async {
    final response = await _dio.post(
      '/preview/$templateId',
      data: cvData.toJson(),
      options: Options(responseType: ResponseType.plain),
    );
    return response.data;
  }

  Future<Response> downloadCv(String templateId, CreateCvDto cvData) async {
    return await _dio.post(
      '/download/$templateId',
      data: cvData.toJson(),
      options: Options(
        responseType: ResponseType.bytes,
        validateStatus: (status) => status != null,
      ),
    );
  }

  // [NEW] Lấy danh sách CV
  Future<List<UserCVEntity>> getMyCvs() async {
    try {
      final response = await _dio.get('/my-cvs');
      return (response.data['data'] as List)
          .map((json) => UserCVEntity.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Lỗi lấy danh sách CV: $e');
    }
  }

  // [NEW] Upload CV
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

  // [NEW] Đặt mặc định
  Future<void> setDefaultCv(int cvId) async {
    try {
      await _dio.patch('/$cvId/set-default');
    } catch (e) {
      throw Exception('Lỗi đặt mặc định: $e');
    }
  }

  // [NEW] Xóa CV
  Future<void> deleteCv(int cvId) async {
    try {
      await _dio.delete('/$cvId');
    } catch (e) {
      throw Exception('Lỗi xóa CV: $e');
    }
  }
}
