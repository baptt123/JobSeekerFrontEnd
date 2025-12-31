import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class CvGenerationService {
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}');

  // 1. Upload & Rút trích Keyword (Backend dùng Gemini File Search)
  Future<Map<String, dynamic>> uploadCv(PlatformFile file) async {
    FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(file.path!, filename: file.name),
    });
    try {
      final response = await _dio.post('/cv/upload-extract', data: formData);
      return response.data; // Trả về { cv: object, keywords: string }
    } catch (e) {
      throw e;
    }
  }

  // 2. Tạo CV bằng Gemini (Nhận về file PDF bytes)
  Future<List<int>> generateCvGemini(String prompt) async {
    try {
      final response = await _dio.post(
        '/cv/generate-ai',
        data: {'prompt': prompt},
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      throw e;
    }
  }

  // 3. Tạo CV từ Template
  Future<List<int>> generateCvTemplate(int templateId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/cv/generate-template',
        data: {'templateId': templateId, 'data': data},
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } catch (e) {
      throw e;
    }
  }

  // 4. Lấy danh sách CV
  Future<List<dynamic>> getMyCvs() async {
    try {
      final response = await _dio.get('/cv/list');
      return response.data;
    } catch (e) {
      throw e;
    }
  }

  // Xoá mềm CV
  Future<void> deleteCv(int id) async {
    await _dio.delete('/cv/delete/$id');
  }

  // Đặt mặc định
  Future<void> setDefaultCv(int id) async {
    await _dio.patch('/cv/set-default/$id');
  }
}