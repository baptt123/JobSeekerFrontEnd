import 'dart:io';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class PdfScanService {
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/cv');

  Future<File?> pickPdfFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    return (result != null && result.files.single.path != null) ? File(result.files.single.path!) : null;
  }

  Future<String> extractTextFromPdf(File file, int userId) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, contentType: DioMediaType('application', 'pdf')),
      });
      final response = await _dio.post('/scan-pdf', data: formData);
      return response.data['extracted_text'] ?? 'Không có nội dung.';
    } catch (e) {
      throw Exception('Lỗi scan PDF: $e');
    }
  }
}