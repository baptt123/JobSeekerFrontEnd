// lib/view_models/user/cv_generation_view_model.dart

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:job_seeker_frontend/services/cv_service.dart';
import 'package:job_seeker_frontend/dto/create_cv_dto.dart';

enum CvState { initial, loading, success, error }

class CvGenerationViewModel extends ChangeNotifier {
  final CvGenerationService _cvService = CvGenerationService();

  CvState _state = CvState.initial;
  CvState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Uint8List? _previewPdfBytes;
  Uint8List? get previewPdfBytes => _previewPdfBytes;

  Uint8List? _pdfData; // Dùng cho phần AI Generate
  Uint8List? get pdfData => _pdfData;

// Hàm xem trước
  Future<bool> generatePreview(String templateId, CreateCvDto cvData) async {
    _state = CvState.loading;
    notifyListeners();
    try {
      final result = await _cvService.previewCvPdf(templateId, cvData);
      _previewPdfBytes = result;
      _state = CvState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _state = CvState.error;
      notifyListeners();
      return false;
    }
  }

  // Hàm lưu (Đã sửa lỗi thiếu hàm này)
  Future<bool> saveCv(String templateId, CreateCvDto cvData) async {
    try {
      await _cvService.saveGeneratedCv(templateId, cvData);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // 3. Tạo CV bằng AI (Prompt Chat)
  Future<bool> generateCv(String prompt) async {
    _state = CvState.loading;
    _errorMessage = null;
    _pdfData = null;
    notifyListeners();

    try {
      final data = await _cvService.generateCv(prompt);
      if (data.isEmpty) throw Exception("Dữ liệu PDF rỗng");

      _pdfData = data;
      _state = CvState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = CvState.error;
      notifyListeners();
      return false;
    }
  }
}