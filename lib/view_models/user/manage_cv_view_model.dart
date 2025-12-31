import 'package:flutter/material.dart';
import '../../models/user-cv-entity.dart';
import '../../services/cv_service.dart';

class ManageCvViewModel extends ChangeNotifier {
  final CvGenerationService _cvService = CvGenerationService();
  List<UserCvEntity> _cvList = [];
  bool _isLoading = false;

  List<UserCvEntity> get cvList => _cvList;
  bool get isLoading => _isLoading;

  Future<void> fetchCvs() async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _cvService.getMyCvs();
      _cvList = (data as List).map((e) => UserCvEntity.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching CVs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCv(int cvId) async {
    try {
      await _cvService.deleteCv(cvId);
      _cvList.removeWhere((cv) => cv.cvId == cvId);
      notifyListeners();
    } catch (e) {
      print("Delete error: $e");
    }
  }

  Future<void> setDefault(int cvId) async {
    try {
      await _cvService.setDefaultCv(cvId);
      for (var cv in _cvList) {
        cv.isDefault = (cv.cvId == cvId);
      }
      notifyListeners();
    } catch (e) {
      print("Set default error: $e");
    }
  }
}