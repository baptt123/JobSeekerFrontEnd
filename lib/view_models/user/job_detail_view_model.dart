// lib/view_models/user/job_detail_view_model.dart

import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/services/job_application_service.dart';
import 'package:provider/provider.dart'; // ⭐️ Import provider

import '../../models/job-entity.dart';
import '../../services/job_service.dart';
// ⭐️ Import 2 ViewModels để đồng bộ
import 'home_view_model.dart';
import 'save_job_view_model.dart';

class JobDetailViewModel extends ChangeNotifier {
  JobEntity? _job;
  JobEntity? get job => _job;
  final JobApplicationService _jobApplicationService = JobApplicationService();
  final JobService _jobService = JobService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  bool _isApplying = false;
  bool get isApplying => _isApplying;

  bool _isApplied = false;
  bool get isApplied => _isApplied;

  // --- ⭐️ LOGIC MỚI CHO 'SAVE' ---
  bool _isSaving = false; // 1. Thêm cờ "đang xử lý"
  bool get isSaving => _isSaving;

  bool _isSaved = false; // 2. Thêm cờ "đã lưu"
  bool get isSaved => _isSaved;
  // --- KẾT THÚC LOGIC MỚI ---

  Future<void> fetchJobDetail(String jobTitle) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _job = await _jobService.getJobDetail(jobTitle);

      if (_job != null) {
        _isApplied = _job!.isApplied;
        _isSaved = _job!.isSaved; // ⭐️ CẬP NHẬT: Lấy 'isSaved' từ job
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // (Hàm applyForJob giữ nguyên)
  Future<void> applyForJob(BuildContext context) async {
    if (_isApplying || _isApplied) return;

    _isApplying = true;
    notifyListeners();

    try {
      await _jobApplicationService.applyForJob(_job!.jobId);
      _isApplied = true;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nộp đơn thành công!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nộp đơn thất bại: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isApplying = false;
      notifyListeners();
    }
  }

  // ⭐️ HÀM MỚI: XỬ LÝ TOGGLE SAVE JOB
  Future<void> toggleSaveJob(BuildContext context) async {
    if (_isSaving || _job == null) return; // Không cho bấm khi đang xử lý

    _isSaving = true;
    final bool originalSaveState = _isSaved; // Lưu trạng thái cũ
    _isSaved = !_isSaved; // 1. Cập nhật UI ngay (Optimistic Update)
    notifyListeners();

    // 2. Lấy các ViewModels khác để đồng bộ
    // Dùng read() vì chúng ta ở bên ngoài hàm build
    // (Điều này yêu cầu HomeViewModel và SavedJobsViewModel đã được
    // cung cấp ở cấp cao hơn trong cây widget, ví dụ: main.dart)
    final homeViewModel = context.read<HomeViewModel>();
    final savedJobsViewModel = context.read<SavedJobsViewModel>();

    try {
      if (_isSaved) {
        // 3a. Nếu trạng thái mới là "Đã lưu" -> Gọi API save
        await _jobService.saveJob(_job!.jobId);
        // Đồng bộ:
        homeViewModel.addSavedId(_job!.jobId);
        savedJobsViewModel.addSavedJob(_job!);
      } else {
        // 3b. Nếu trạng thái mới là "Bỏ lưu" -> Gọi API unsave
        await _jobService.unsaveJob(_job!.jobId);
        // Đồng bộ:
        homeViewModel.removeSavedId(_job!.jobId);
        savedJobsViewModel.removeSavedJob(_job!.jobId);
      }
    } catch (e) {
      // 4. Nếu lỗi -> Quay lại trạng thái cũ
      _isSaved = originalSaveState;
      notifyListeners(); // Cập nhật lại UI

      // Hiển thị lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}