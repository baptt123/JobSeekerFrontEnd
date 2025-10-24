import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../services/pdf_scan_service.dart';

class ScanPdfViewModel extends ChangeNotifier {
  final PdfScanService _pdfScanService = PdfScanService();

  // --- Trạng thái (State) ---
  bool _isLoading = false;
  String _extractedText = "";
  String _fileName = "";

  // --- Getters cho View ---
  bool get isLoading => _isLoading;
  String get extractedText => _extractedText;
  String get fileName => _fileName;

  // --- Logic nghiệp vụ (do View gọi) ---
  Future<void> pickAndScanPdf() async {
    _setLoading(true);
    _extractedText = "";
    _fileName = "";

    try {
      // 1. Chọn file
      final File? file = await _pdfScanService.pickPdfFile();

      // Nếu người dùng không chọn file
      if (file == null) {
        _setLoading(false);
        return;
      }

      _fileName = file.path.split('/').last;
      notifyListeners(); // Cập nhật tên file lên UI ngay

      // 2. Scan file
      _extractedText = await _pdfScanService.extractTextFromPdf(file);

    } catch (e) {
      _extractedText = "Đã xảy ra lỗi: ${e.toString()}";
    } finally {
      // 3. Cập nhật UI
      _setLoading(false);
    }
  }

  // Hàm private để quản lý trạng thái loading và thông báo cho View
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}