import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart'; // Để dùng BuildContext nếu cần lấy UserProvider

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

  // --- Logic nghiệp vụ ---
  Future<void> pickAndScanPdf(BuildContext context) async {
    _setLoading(true);
    _extractedText = "";
    _fileName = "";

    try {
      // 1. Giả lập lấy User ID hiện tại
      // TODO: Thay thế dòng này bằng Provider.of<UserViewModel>(context, listen: false).user.id
      const int currentUserId = 1;

      // 2. Chọn file
      final File? file = await _pdfScanService.pickPdfFile();

      if (file == null) {
        _setLoading(false); // Người dùng hủy chọn
        return;
      }

      _fileName = file.path.split('/').last;
      notifyListeners(); // Cập nhật UI để hiện tên file và vòng quay loading

      // 3. Scan file (Gửi kèm userId)
      _extractedText = await _pdfScanService.extractTextFromPdf(file, currentUserId);

    } catch (e) {
      _extractedText = "❌ Đã xảy ra lỗi: ${e.toString()}";
    } finally {
      _setLoading(false);
    }
  }

  // Hàm private update loading
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}