// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:file_picker/file_picker.dart';
// import '../../services/cv_service.dart';
//
// class ScanPdfViewModel extends ChangeNotifier {
//   final CVService _cvService = CVService();
//
//   bool _isLoading = false;
//   bool get isLoading => _isLoading;
//
//   String? _extractedKeywords;
//   String? get extractedKeywords => _extractedKeywords;
//
//   String? _errorMessage;
//   String? get errorMessage => _errorMessage;
//
//   // Hàm chọn file và upload
//   Future<bool> pickAndUploadCv() async {
//     _errorMessage = null;
//     _extractedKeywords = null;
//
//     // 1. Chọn file
//     FilePickerResult? result = await FilePicker.platform.pickFiles(
//       type: FileType.custom,
//       allowedExtensions: ['pdf'],
//     );
//
//     if (result == null) return false; // Người dùng hủy chọn
//
//     File file = File(result.files.single.path!);
//
//     // Validation Frontend
//     if (!file.path.toLowerCase().endsWith('.pdf')) {
//       _errorMessage = "Vui lòng chỉ chọn file định dạng PDF.";
//       notifyListeners();
//       return false;
//     }
//
//     // 2. Upload
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       // API trả về json { message, cv, keywords }
//       final response = await _cvService.uploadCV(file);
//
//       if (response != null && response['keywords'] != null) {
//         _extractedKeywords = response['keywords'];
//       } else {
//         _extractedKeywords = "Không xác định";
//       }
//
//       return true; // Thành công
//     } catch (e) {
//       _errorMessage = e.toString();
//       return false;
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
// }