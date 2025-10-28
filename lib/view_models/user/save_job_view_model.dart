import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/models/job-entity.dart';
import 'package:job_seeker_frontend/services/job_service.dart';
import 'package:job_seeker_frontend/view_models/user/home_view_model.dart';

// Enum để theo dõi trạng thái tải dữ liệu
enum SavedJobsState { loading, loaded, error }

class SavedJobsViewModel extends ChangeNotifier {
  final JobService _apiService = JobService();

  SavedJobsState _state = SavedJobsState.loading;
  SavedJobsState get state => _state;

  List<JobEntity> _savedJobs = [];
  List<JobEntity> get savedJobs => _savedJobs;

  String _error = '';
  String get error => _error;

  // Hàm tiện ích hiển thị snackbar
  void _showSnackbar(BuildContext context, String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  /// 1. Tải danh sách các job đã lưu từ API
  Future<void> fetchSavedJobs() async {
    _state = SavedJobsState.loading;
    notifyListeners();
    try {
      // Gọi service để lấy job
      _savedJobs = await _apiService.getSavedJobs();
      _state = SavedJobsState.loaded;
    } catch (e) {
      _error = e.toString();
      _state = SavedJobsState.error;
    }
    notifyListeners();
  }

  /// 2. Xóa một job khỏi danh sách đã lưu (gọi từ màn hình này)
  Future<void> unsaveJob(
      JobEntity job,
      BuildContext context,
      HomeViewModel homeViewModel, // Nhận HomeViewModel để đồng bộ
      ) async {
    try {
      final jobId = job.jobId;
      // Gọi API để xóa (soft-delete)
      await _apiService.unsaveJob(jobId);

      // Xóa khỏi danh sách hiện tại (Optimistic update)
      _savedJobs.removeWhere((j) => j.jobId == jobId);

      // Đồng bộ ngược lại với HomeViewModel (cập nhật icon ở Trang chủ)
      homeViewModel.removeSavedId(jobId);

      _showSnackbar(context, 'Đã xóa job thành công', false);
      notifyListeners();
    } catch (e) {
      _showSnackbar(context, 'Đã xảy ra lỗi: $e', true);
    }
  }

  // === CÁC HÀM ĐỒNG BỘ STATE (Được gọi bởi HomeViewModel) ===

  /// 3. Thêm job vào danh sách khi user lưu từ màn hình Home
  void addSavedJob(JobEntity job) {
    // Kiểm tra để không thêm trùng
    if (!_savedJobs.any((j) => j.jobId == job.jobId)) {
      _savedJobs.insert(0, job); // Thêm vào đầu danh sách
      notifyListeners();
    }
  }

  /// 4. Xóa job khỏi danh sách khi user hủy lưu từ màn hình Home
  void removeSavedJob(int jobId) {
    _savedJobs.removeWhere((j) => j.jobId == jobId);
    notifyListeners();
  }
}