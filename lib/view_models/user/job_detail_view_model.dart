// lib/view_models/user/job_detail_view_model.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/job-entity.dart';
import '../../models/user-cv-entity.dart';
import '../../services/job_service.dart';
import '../../services/job_application_service.dart';
import '../../services/cv_service.dart';
import 'home_view_model.dart';
import 'save_job_view_model.dart';

class JobDetailViewModel extends ChangeNotifier {
  final JobApplicationService _jobApplicationService = JobApplicationService();
  final JobService _jobService = JobService();
  final CvGenerationService _cvService = CvGenerationService();

  JobEntity? _job;
  JobEntity? get job => _job;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // --- State cho phần Apply ---
  bool _isLoadingCvs = false;
  bool get isLoadingCvs => _isLoadingCvs;

  List<UserCVEntity> _myCvs = [];
  List<UserCVEntity> get myCvs => _myCvs;

  bool _isApplying = false;
  bool get isApplying => _isApplying;

  bool _isApplied = false;
  bool get isApplied => _isApplied;

  bool _isSaved = false;
  bool get isSaved => _isSaved;
  bool _isSaving = false;

  String? _errorMessage;

  // 1. Fetch Job Detail
  Future<void> fetchJobDetail(String jobTitle) async {
    _isLoading = true;
    notifyListeners();
    try {
      _job = await _jobService.getJobDetail(jobTitle);
      if (_job != null) {
        _isApplied = _job!.isApplied;
        _isSaved = _job!.isSaved;
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Lấy danh sách CV (Reset list trước khi load để tránh hiện cũ)
  Future<void> fetchMyCvs() async {
    _isLoadingCvs = true;
    _myCvs = []; // Reset list
    notifyListeners();
    try {
      _myCvs = await _cvService.getMyCvs();
    } catch (e) {
      debugPrint("Lỗi lấy CV: $e");
    } finally {
      _isLoadingCvs = false;
      notifyListeners();
    }
  }

  // 3. Gửi Ứng Tuyển (Đã cập nhật xử lý lỗi hiển thị đẹp hơn)
  Future<bool> submitApplication(BuildContext context, int? selectedCvId, String coverLetter) async {
    // Validate cơ bản
    if (_isApplying || _job == null) return false;

    if (selectedCvId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Vui lòng chọn 1 CV để ứng tuyển"), backgroundColor: Colors.orange)
        );
      }
      return false;
    }

    _isApplying = true;
    notifyListeners();

    try {
      await _jobApplicationService.applyForJob(
        jobId: _job!.jobId,
        cvId: selectedCvId,
        coverLetter: coverLetter,
      );

      _isApplied = true;
      _isApplying = false;
      notifyListeners();

      return true; // ✅ Thành công
    } catch (e) {
      _isApplying = false;
      notifyListeners();

      // --- XỬ LÝ LỖI THÔNG MINH ---
      String errorMsg = e.toString().replaceAll("Exception: ", "");

      // Nếu lỗi trả về dạng JSON string như "{message: ..., error: ...}"
      // Ta sẽ cố gắng lấy phần message để hiển thị cho thân thiện
      if (errorMsg.contains("message:") && errorMsg.contains("}")) {
        // Cách đơn giản: tách chuỗi (hoặc bạn có thể dùng jsonDecode nếu chuỗi chuẩn JSON)
        // Ví dụ chuỗi: {message: Công việc hết hạn, error: Bad Request...}
        try {
          final start = errorMsg.indexOf("message:") + 8;
          final end = errorMsg.indexOf(",", start);
          if (end != -1) {
            errorMsg = errorMsg.substring(start, end).trim();
          }
        } catch (_) {
          // Nếu parse lỗi thì giữ nguyên errorMsg gốc
        }
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorMsg),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating, // Nổi lên trên cho đẹp
            )
        );
      }
      return false; // ❌ Thất bại
    }
  }

  // 4. Toggle Save
  Future<void> toggleSaveJob(BuildContext context) async {
    if (_isSaving || _job == null) return;

    _isSaving = true;
    final originalState = _isSaved;
    _isSaved = !_isSaved; // Optimistic update (cập nhật giao diện trước)
    notifyListeners();

    try {
      if (_isSaved) {
        await _jobService.saveJob(_job!.jobId);
      } else {
        await _jobService.unsaveJob(_job!.jobId);
      }

      // Sync data với các màn hình khác (Home, SavedJobs)
      if (context.mounted) {
        context.read<HomeViewModel>().fetchInitialData();
        context.read<SavedJobsViewModel>().fetchSavedJobs();
      }
    } catch (e) {
      _isSaved = originalState; // Revert nếu lỗi
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Lỗi thao tác: ${e.toString().replaceAll("Exception: ", "")}"))
        );
      }
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}