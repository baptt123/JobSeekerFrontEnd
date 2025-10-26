import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import '../../services/cv_service.dart'; // Để dùng ChangeNotifier

// Các trạng thái của view
enum CvGenerationState { initial, loading, success, error }

class CvGenerationViewModel extends ChangeNotifier {
  final CvGenerationService _cvService=CvGenerationService();

  CvGenerationViewModel();

  // Trạng thái (State)
  CvGenerationState _state = CvGenerationState.initial;
  CvGenerationState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Uint8List? _pdfData;
  Uint8List? get pdfData => _pdfData;

  // Hàm xử lý logic chính
  Future<void> generateCv(String prompt) async {
    // 1. Cập nhật trạng thái sang "Loading"
    _state = CvGenerationState.loading;
    _errorMessage = null;
    _pdfData = null;
    notifyListeners(); // Báo cho View "vẽ lại"

    try {
      // 2. Gọi Service
      final data = await _cvService.generateCv(prompt);

      // 3. Thành công
      _pdfData = data;
      _state = CvGenerationState.success;
    } catch (e) {
      // 4. Thất bại
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _state = CvGenerationState.error;
    } finally {
      // 5. Báo cho View "vẽ lại" lần nữa
      notifyListeners();
    }
  }

  // Hàm để reset trạng thái khi người dùng quay lại
  void resetState() {
    _state = CvGenerationState.initial;
    _errorMessage = null;
    _pdfData = null;
    notifyListeners();
  }
}