import 'dart:io';
import 'dart:typed_data'; // Để xử lý Bytes
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart'; // Để tải ảnh từ URL
import '../../services/cv_service.dart';
import '../../services/pdf_template_builder_service.dart'; // Import Service Builder Frontend
import '../../dto/create_cv_dto.dart'; // Import DTO

class CvGenerationViewModel extends ChangeNotifier {
  final CVService _cvService = CVService();
  final PdfTemplateBuilderService _pdfBuilder = PdfTemplateBuilderService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Helper lưu file PDF vào thư mục tạm
  Future<File> _saveBytesToTempFile(List<int> bytes, String prefix) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // Helper: Tải ảnh từ URL về dạng Bytes (dùng cho ảnh profile online)
  Future<Uint8List?> _fetchImageBytesFromUrl(String url) async {
    try {
      if (url.isEmpty) return null;
      final response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );
      return Uint8List.fromList(response.data);
    } catch (e) {
      print("Lỗi tải ảnh profile: $e");
      return null;
    }
  }

  // Tạo CV AI (Giữ nguyên logic cũ dùng Backend API)
  Future<File?> generateCvByAi(String prompt) async {
    if (prompt.isEmpty) {
      _errorMessage = "Vui lòng nhập mô tả bản thân.";
      notifyListeners();
      return null;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Gọi service backend lấy bytes từ Gemini API
      List<int> pdfBytes = await _cvService.generateCVAI(prompt);

      if (pdfBytes.length < 100) throw Exception("File PDF bị lỗi hoặc rỗng.");

      File file = await _saveBytesToTempFile(pdfBytes, "cv_ai");
      return file;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception:", "").trim();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tạo CV Template (Logic Frontend hoàn toàn)
  Future<File?> generateCvFromTemplate(
      int templateId,
      Map<String, dynamic> data,
      {File? localImageFile, String? onlineImageUrl} // Tham số ảnh
      ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (data['fullName'] == null || data['fullName'].toString().isEmpty) {
        throw Exception("Vui lòng nhập họ tên.");
      }

      // 1. Convert Map sang DTO
      CreateCvDto cvDto = CreateCvDto.fromJson(data);

      // 2. Xử lý ảnh: Ưu tiên ảnh từ file máy > ảnh online > null
      Uint8List? avatarBytes;
      if (localImageFile != null) {
        // Đọc bytes từ file local
        avatarBytes = await localImageFile.readAsBytes();
      } else if (onlineImageUrl != null && onlineImageUrl.isNotEmpty) {
        // Tải bytes từ URL profile
        avatarBytes = await _fetchImageBytesFromUrl(onlineImageUrl);
      }

      // 3. Map ID sang tên template
      String templateName = 'modern';
      switch(templateId) {
        case 1: templateName = 'modern'; break;
        case 2: templateName = 'classic'; break;
        case 3: templateName = 'professional'; break;
        case 4: templateName = 'creative'; break;
      }

      // 4. Gọi Service tạo PDF tại Frontend
      List<int> pdfBytes = await _pdfBuilder.buildPdf(
          cvDto,
          templateId: templateName,
          avatarBytes: avatarBytes
      );

      if (pdfBytes.length < 100) {
        throw Exception("File PDF tạo ra bị lỗi dữ liệu.");
      }

      File file = await _saveBytesToTempFile(pdfBytes, "cv_template_$templateId");
      return file;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception:", "").trim();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}