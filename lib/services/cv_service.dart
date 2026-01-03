import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class CVService {
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}');

  // 1. Upload CV (Giữ nguyên)
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

  // 2. Generate AI (UPDATED: Nhận Bytes PDF)
  Future<List<int>> generateCVAI(String prompt) async {
    try {
      Response response = await _dio.post(
        '/cv/generate-ai',
        data: {"prompt": prompt},
        options: Options(
          responseType: ResponseType.bytes, // Quan trọng: Nhận dữ liệu nhị phân
          receiveTimeout: Duration(seconds: 90), // Tăng timeout cho tác vụ AI
        ),
      );
      return response.data;
    } on DioException catch (e) {
      // Nếu Backend trả về lỗi JSON thay vì file
      if (e.response != null && e.response?.headers.value('content-type')?.contains('json') == true) {
        // Thử parse lỗi từ buffer nếu cần, nhưng thường Dio sẽ throw ở đây
      }
      throw Exception('Không thể tạo CV lúc này. Vui lòng thử lại sau.');
    }
  }

  // 3. Generate Template (Giữ nguyên)
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

  // 4. Quản lý CV (Giữ nguyên)
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
  // --- HÀM MỚI: Upload & Parse AI ---
  Future<dynamic> uploadAndParseCv(File file) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: MediaType('application', 'pdf'),
      ),
    });

    try {
      // Gọi endpoint mới ở Backend
      Response response = await _dio.post(
        '/cv/upload-parse-cv',
        data: formData,
        // Tăng timeout vì AI xử lý có thể lâu (10-30s)
        options: Options(receiveTimeout: const Duration(seconds: 60)),
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw Exception(e.response!.data['message'] ?? 'Lỗi xử lý CV');
      }
      throw Exception('Lỗi kết nối server: ${e.message}');
    }
  }
}