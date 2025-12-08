// lib/services/pdf_scan_service.dart

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class PdfScanService {
  // Đường dẫn base phải trỏ tới '/cv' vì controller là 'cv'
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/cv');

  // Chọn file
  Future<File?> pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf']
    );
    return (result != null && result.files.single.path != null)
        ? File(result.files.single.path!)
        : null;
  }

  // Upload và Scan
  Future<Map<String, dynamic>> scanAndSavePdf(File file) async {
    try {
      String fileName = file.path.split('/').last;

      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
          // contentType: MediaType('application', 'pdf'), // Nếu cần thiết
        ),
      });

      // Gọi API scan-pdf
      final response = await _dio.post('/scan-pdf', data: formData);

      // Trả về data thành công
      return response.data;
    } on DioException catch (e) {
      // Lấy thông báo lỗi từ backend (BadRequestException...)
      final errorMsg = e.response?.data['message'] ?? 'Lỗi kết nối khi quét PDF';
      throw Exception(errorMsg);
    }
  }
}