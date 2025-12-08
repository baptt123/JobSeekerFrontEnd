// lib/view_models/user/scan_pdf_view_model.dart

import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/pdf_scan_service.dart';

class ScanPdfViewModel extends ChangeNotifier {
  final PdfScanService _pdfScanService = PdfScanService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _fileName;
  String? get fileName => _fileName;

  File? _selectedFile; // Lưu file đã chọn

  // 1. Chỉ chọn file (chưa upload)
  Future<void> pickPdf() async {
    final file = await _pdfScanService.pickPdfFile();
    if (file != null) {
      _selectedFile = file;
      _fileName = file.path.split('/').last;
      notifyListeners();
    }
  }

  // 2. Thực hiện Upload & Scan
  Future<void> uploadAndScan(BuildContext context) async {
    if (_selectedFile == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      // Gọi Service
      final result = await _pdfScanService.scanAndSavePdf(_selectedFile!);

      // Thành công
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Phân tích và lưu CV thành công!'), backgroundColor: Colors.green),
        );
        // Có thể navigate sang trang quản lý CV hoặc hiển thị kết quả
        Navigator.pushReplacementNamed(context, '/manage_cv');
      }

      // Reset
      _fileName = null;
      _selectedFile = null;

    } catch (e) {
      // Thất bại
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ ${e.toString().replaceAll("Exception: ", "")}'), backgroundColor: Colors.red),
        );
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearFile() {
    _fileName = null;
    _selectedFile = null;
    notifyListeners();
  }
}