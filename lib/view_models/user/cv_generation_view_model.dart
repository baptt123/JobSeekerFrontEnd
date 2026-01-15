import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../services/cv_service.dart';

class CvGenerationViewModel extends ChangeNotifier {
  final CVService _cvService = CVService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Helper lưu file PDF vào thư mục tạm
  Future<File> _saveBytesToTempFile(List<int> bytes, String prefix) async {
    final tempDir = await getTemporaryDirectory();
    // Thêm timestamp để tên file không bị trùng
    final fileName = '${prefix}_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final file = File('${tempDir.path}/$fileName');
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  // Tạo CV AI (Logic cho Gemini)
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
      // Gọi service lấy bytes từ Gemini API
      List<int> pdfBytes = await _cvService.generateCVAI(prompt);

      if (pdfBytes.length < 100) throw Exception("File PDF bị lỗi hoặc rỗng.");

      // Lưu thành file tạm và trả về File object cho View
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

  // Tạo CV Template (Logic Template)
  Future<File?> generateCvFromTemplate(int templateId, Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Validate dữ liệu cơ bản
      if (data['fullName'] == null || data['fullName'].toString().isEmpty) {
        throw Exception("Vui lòng nhập họ tên.");
      }

      // Gọi service, truyền đúng cấu trúc DTO mới
      List<int> pdfBytes = await _cvService.generateCVTemplate(templateId, data);

      if (pdfBytes.length < 100) {
        throw Exception("File PDF tạo ra bị lỗi dữ liệu.");
      }

      File file = await _saveBytesToTempFile(pdfBytes, "cv_template_$templateId");
      return file;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception:", "").trim();
      if (_errorMessage!.contains("SocketException")) _errorMessage = "Lỗi kết nối mạng.";
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}