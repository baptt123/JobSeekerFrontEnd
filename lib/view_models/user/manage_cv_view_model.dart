import 'dart:io';
import 'package:flutter/material.dart';
import '../../services/cv_service.dart';
// Import model UserCVEntity nếu bạn đã có, hoặc dùng dynamic tạm thời
import '../../models/user-cv-entity.dart';

class ManageCvViewModel extends ChangeNotifier {
  final CVService _cvService = CVService();

  List<dynamic> _cvList = []; // Danh sách CV
  List<dynamic> get cvList => _cvList;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Lấy danh sách CV
  Future<void> getMyCVs() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cvList = await _cvService.getMyCVs();
    } catch (e) {
      _errorMessage = e.toString();
      print("Error fetching CVs: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Đặt CV làm mặc định
  Future<bool> setDefaultCv(int cvId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _cvService.setDefaultCV(cvId);
      // Refresh lại list để cập nhật UI icon mặc định
      await getMyCVs();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Xóa mềm CV
  Future<bool> deleteCv(int cvId) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _cvService.deleteCV(cvId);
      // Xóa thành công thì load lại list
      await getMyCVs();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}