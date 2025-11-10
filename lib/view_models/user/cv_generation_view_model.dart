//
// 📄 [SỬA ĐỔI] baptt123/jobseekerfrontend/JobSeekerFrontEnd-develop/lib/view_models/user/cv_generation_view_model.dart
//
import 'dart:typed_data';
// Sửa import 'dio' thành 'http' nếu bạn dùng package http
import 'package:dio/src/response.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

// Đảm bảo đường dẫn này đúng
import 'package:job_seeker_frontend/services/cv_service.dart';
import 'package:job_seeker_frontend/dto/create_cv_dto.dart';

// Các trạng thái của view
enum CvGenerationState { initial, loading, success, error }

class CvGenerationViewModel extends ChangeNotifier {
  // Đảm bảo tên class Service khớp (CvGenerationService)
  final CvGenerationService _cvService = CvGenerationService();

  // Trạng thái (State) cho chức năng Gemini
  CvGenerationState _state = CvGenerationState.initial;
  CvGenerationState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Uint8List? _pdfData;
  Uint8List? get pdfData => _pdfData;

  // Hàm xử lý logic chính (Gemini)
  Future<void> generateCv(String prompt) async {
    // 1. Cập nhật trạng thái sang "Loading"
    _state = CvGenerationState.loading;
    _errorMessage = null;
    _pdfData = null;
    notifyListeners(); // Báo cho View "vẽ lại"

    try {
      // 2. Gọi Service (Service này giờ trả về Uint8List)
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

  /*
  ================================================================
  CHỨC NĂNG TẠO CV TỪ TEMPLATE (Giữ nguyên)
  ================================================================
  */

  Future<String> previewCv(String templateId, CreateCvDto cvData) async {
    try {
      final htmlString = await _cvService.previewCv(templateId, cvData);
      return htmlString;
    } catch (e) {
      throw e;
    }
  }

  Future<Response> downloadCv(String templateId, CreateCvDto cvData) async {
    try {
      final response = await _cvService.downloadCv(templateId, cvData);
      return response;
    } catch (e) {
      throw e;
    }
  }
}