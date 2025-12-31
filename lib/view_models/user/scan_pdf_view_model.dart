import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../services/cv_service.dart';

class ScanPdfViewModel extends ChangeNotifier {
  final CvGenerationService _cvService = CvGenerationService();

  bool _isLoading = false;
  String? _keywords;
  String? _error;

  bool get isLoading => _isLoading;
  String? get keywords => _keywords;
  String? get error => _error;

  Future<void> pickAndUploadPdf() async {
    _error = null;
    _keywords = null;

    // Check định dạng file PDF
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      if (file.extension != 'pdf') {
        _error = "Vui lòng chọn file đúng định dạng .pdf";
        notifyListeners();
        return;
      }

      _isLoading = true;
      notifyListeners();

      try {
        // Gọi Service gửi xuống Backend
        final res = await _cvService.uploadCv(file);
        _keywords = res['keywords'];
      } catch (e) {
        _error = "Lỗi upload: $e";
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  void clearState() {
    _error = null;
    _keywords = null;
    notifyListeners();
  }
}