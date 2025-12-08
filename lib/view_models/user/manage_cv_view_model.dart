import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:job_seeker_frontend/models/user-cv-entity.dart';
import 'package:job_seeker_frontend/services/cv_service.dart';
import 'package:provider/provider.dart'; // Cần import Provider
import 'package:job_seeker_frontend/view_models/user/home_view_model.dart'; // Cần import HomeViewModel

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

  Future<void> uploadNewCv(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ['pdf'],
      );

      if (result != null) {
        File file = File(result.files.single.path!);
        String fileName = result.files.single.name;
        String? title = await _showTitleDialog(context, fileName);
        if (title == null) return;

        _state = ManageCvState.uploading;
        notifyListeners();

        await _cvService.uploadCv(file, title);
        await fetchCvs(); // Reload danh sách

        if(context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Upload thành công!'), backgroundColor: Colors.green));
        }
      }
    } catch (e) {
      _errorMessage = e.toString();
      _state = ManageCvState.error; // Hoặc loaded để hiện lại list cũ
      notifyListeners();
      fetchCvs(); // Reload lại để đảm bảo state đúng
    }
  }

  // --- LOGIC MỚI: ĐẶT MẶC ĐỊNH & RELOAD HOME ---
  Future<void> setDefault(int cvId, BuildContext context) async {
    try {
      await _cvService.setDefaultCv(cvId);

      // 1. Reload danh sách CV tại màn hình này để cập nhật tick xanh
      await fetchCvs();

      // 2. Báo hiệu cho HomeViewModel reload dữ liệu gợi ý việc làm
      if (context.mounted) {
        Provider.of<HomeViewModel>(context, listen: false).fetchInitialData();
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã cập nhật CV chính. Trang chủ sẽ hiển thị việc làm phù hợp mới!'), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

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

  Future<String?> _showTitleDialog(BuildContext context, String defaultName) async {
    TextEditingController controller = TextEditingController(text: defaultName);
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Đặt tên CV"),
        content: TextField(controller: controller, decoration: const InputDecoration(hintText: "Ví dụ: CV Frontend 2025")),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text("Hủy")),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: const Text("Upload")),
        ],
      ),
    );
  }
}