import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class CVService {
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}');
  // 1. Upload CV
  Future<dynamic> uploadCV(File file) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: MediaType('application', 'pdf'),
      ),
    });

    try {
      Response response = await _dio.post(
        '/cv/upload-extract',
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi tải lên CV');
    }
  }

  // 2. Generate AI (Nhận về Bytes PDF)
  Future<List<int>> generateCVAI(String prompt) async {
    try {
      Response response = await _dio.post(
        '/cv/generate-ai',
        data: {"prompt": prompt},
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Lỗi tạo CV AI: ${e.message}');
    }
  }

  // 3. Generate Template (Nhận về Bytes PDF)
  Future<List<int>> generateCVTemplate(int templateId, Map<String, dynamic> data) async {
    try {
      Response response = await _dio.post(
        '/cv/generate-template',
        data: {"templateId": templateId, "data": data},
        options: Options(responseType: ResponseType.bytes),
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception('Lỗi tạo CV từ Template: ${e.message}');
    }
  }

  // 4. Quản lý CV
  Future<List<dynamic>> getMyCVs() async {
    try {
      Response response = await _dio.get('/cv/list');
      return response.data;
    } catch (e) {
      throw Exception('Lỗi lấy danh sách CV');
    }
  }

  Future<void> setDefaultCV(int id) async {
    try {
      await _dio.patch('/cv/set-default/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi đặt mặc định');
    }
  }

  Future<void> deleteCV(int id) async {
    try {
      await _dio.delete('/cv/delete/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Lỗi xóa CV');
    }
  }
}