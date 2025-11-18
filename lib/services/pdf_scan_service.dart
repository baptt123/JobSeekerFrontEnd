import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:job_seeker_frontend/utils/constant_api.dart'; // Đảm bảo import đúng file config của bạn

class PdfScanService {
  // ✅ Endpoint Backend
  final String _backendUrl = '${ConstantAPI.baseUrl}/cv/scan-pdf';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30), // Tăng timeout vì xử lý AI + Cloudinary lâu
    receiveTimeout: const Duration(seconds: 60),
    sendTimeout: const Duration(seconds: 60),
    headers: {'Accept': 'application/json'},
  ));

  /// 1️⃣ Chọn file PDF từ thiết bị
  Future<File?> pickPdfFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
    } catch (e) {
      print("Lỗi khi chọn file: $e");
    }
    return null;
  }

  /// 2️⃣ Gửi file PDF + UserID lên backend
  Future<String> extractTextFromPdf(File file, int userId) async {
    try {
      print("🚀 Đang gửi file ${file.path.split('/').last} (User: $userId) lên $_backendUrl...");

      // Tạo FormData chứa File và UserID
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
          contentType: DioMediaType('application', 'pdf'),
        ),
        // ⭐️ QUAN TRỌNG: Backend yêu cầu user_id
        'user_id': userId.toString(),
      });

      final response = await _dio.post(
        _backendUrl,
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      print("📦 Status code: ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        // ⭐️ Backend trả về key là 'extracted_text' (snake_case)
        return data['extracted_text'] ?? 'Không có nội dung văn bản được trích xuất.';
      } else {
        throw Exception('Lỗi máy chủ: ${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMsg = e.response?.data is Map
            ? e.response?.data['message'] ?? 'Lỗi không xác định từ server'
            : e.response?.data.toString();
        throw Exception('Lỗi Backend: $errorMsg');
      } else {
        throw Exception('Lỗi kết nối: ${e.message}');
      }
    } catch (e) {
      throw Exception('Lỗi xử lý: $e');
    }
  }
}