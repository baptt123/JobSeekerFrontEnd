// lib/view_models/user/manage_cv_view_model.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:job_seeker_frontend/models/user-cv-entity.dart';
import 'package:job_seeker_frontend/services/cv_service.dart';

enum ManageCvState { loading, loaded, empty, error, uploading }

class ManageCvViewModel extends ChangeNotifier {
  final CvGenerationService _cvService = CvGenerationService();

  List<UserCVEntity> _cvs = [];
  List<UserCVEntity> get cvs => _cvs;

  ManageCvState _state = ManageCvState.loading;
  ManageCvState get state => _state;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  ManageCvViewModel() {
    fetchCvs();
  }

  // Tải danh sách
  Future<void> fetchCvs() async {
    _state = ManageCvState.loading;
    notifyListeners();

    try {
      _cvs = await _cvService.getMyCvs();
      _state = _cvs.isEmpty ? ManageCvState.empty : ManageCvState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _state = ManageCvState.error;
    }
    notifyListeners();
  }

  // Upload CV mới
  Future<void> uploadNewCv(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;

        // Hỏi tên CV (Optional)
        String? title = await _showTitleDialog(context, fileName);
        if (title == null) return; // User hủy

        _state = ManageCvState.uploading;
        notifyListeners();

        await _cvService.uploadCv(file, title);

        // Reload list
        await fetchCvs();

        if(context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload thành công!'), backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      _state = ManageCvState.error; // Hoặc loaded để hiện lại list cũ
      _errorMessage = e.toString();
      notifyListeners();
      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $_errorMessage'), backgroundColor: Colors.red));
      }
      // Reload lại để đảm bảo state đúng
      fetchCvs();
    }
  }

  // Đặt mặc định
  Future<void> setDefault(int cvId) async {
    try {
      await _cvService.setDefaultCv(cvId);
      // Cập nhật UI local trước cho mượt (Optimistic update)
      for (var cv in _cvs) {
        // Cần copyWith hoặc sửa trực tiếp nếu model cho phép (ở đây sửa logic hiển thị)
        // Cách tốt nhất là fetch lại để đồng bộ server
      }
      await fetchCvs();
    } catch (e) {
      print(e);
    }
  }

  // Xóa CV
  Future<void> deleteCv(int cvId, BuildContext context) async {
    try {
      await _cvService.deleteCv(cvId);
      _cvs.removeWhere((cv) => cv.cvId == cvId);
      if (_cvs.isEmpty) _state = ManageCvState.empty;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa CV')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi xóa: $e')));
    }
  }

  // Helper Dialog nhập tên
  Future<String?> _showTitleDialog(BuildContext context, String defaultName) async {
    TextEditingController controller = TextEditingController(text: defaultName);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Đặt tên CV"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Ví dụ: CV Frontend 2025"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text("Upload")),
        ],
      ),
    );
  }
}