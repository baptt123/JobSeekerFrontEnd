import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../services/cv_service.dart';

class CvGenerationViewModel extends ChangeNotifier {
  final CvGenerationService _cvService = CvGenerationService();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Tạo CV bằng Gemini
  Future<Uint8List?> generateByGemini(String prompt) async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<int> bytes = await _cvService.generateCvGemini(prompt);
      return Uint8List.fromList(bytes);
    } catch (e) {
      print("Gemini Gen Error: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Tạo CV bằng Template
  Future<Uint8List?> generateByTemplate(int templateId, Map<String, dynamic> inputData) async {
    _isLoading = true;
    notifyListeners();
    try {
      final List<int> bytes = await _cvService.generateCvTemplate(templateId, inputData);
      return Uint8List.fromList(bytes);
    } catch (e) {
      print("Template Gen Error: $e");
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}