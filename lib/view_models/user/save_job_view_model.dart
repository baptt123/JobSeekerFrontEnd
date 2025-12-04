import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // ✅ Import Storage
import 'package:job_seeker_frontend/models/job-entity.dart';
import 'package:job_seeker_frontend/services/job_service.dart';
import 'package:job_seeker_frontend/view_models/user/home_view_model.dart';

// ✅ Thêm trạng thái unauthorized (chưa đăng nhập)
enum SavedJobsState { loading, loaded, error, unauthorized }

class SavedJobsViewModel extends ChangeNotifier {
  final JobService _apiService = JobService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage(); // ✅ Khai báo Storage

  SavedJobsState _state = SavedJobsState.loading;
  SavedJobsState get state => _state;

  List<JobEntity> _savedJobs = [];
  List<JobEntity> get savedJobs => _savedJobs;

  String _error = '';
  String get error => _error;

  void _showSnackbar(BuildContext context, String message, bool isError) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// 1. Tải danh sách các job đã lưu (CÓ KIỂM TRA ĐĂNG NHẬP)
  Future<void> fetchSavedJobs() async {
    _state = SavedJobsState.loading;
    notifyListeners();

    try {
      // ✅ Bước 1: Kiểm tra xem có token (đã đăng nhập) hay không
      final token = await _storage.read(key: 'accessToken');

      if (token == null) {
        // Nếu chưa đăng nhập -> Chuyển sang trạng thái Unauthorized
        _state = SavedJobsState.unauthorized;
        notifyListeners();
        return; // Dừng, không gọi API
      }

      // ✅ Bước 2: Nếu đã đăng nhập -> Gọi API
      _savedJobs = await _apiService.getSavedJobs();
      _state = SavedJobsState.loaded;
    } catch (e) {
      // Nếu lỗi 401 (Token hết hạn) thì cũng coi như chưa đăng nhập
      if (e.toString().contains("401")) {
        _state = SavedJobsState.unauthorized;
      } else {
        _error = e.toString();
        _state = SavedJobsState.error;
      }
    }
    notifyListeners();
  }

  /// 2. Xóa một job khỏi danh sách đã lưu
  Future<void> unsaveJob(
      JobEntity job,
      BuildContext context,
      HomeViewModel homeViewModel,
      ) async {
    try {
      final jobId = job.jobId;
      await _apiService.unsaveJob(jobId);

      _savedJobs.removeWhere((j) => j.jobId == jobId);
      homeViewModel.removeSavedId(jobId);

      _showSnackbar(context, 'Đã xóa job thành công', false);
      notifyListeners();
    } catch (e) {
      _showSnackbar(context, 'Đã xảy ra lỗi: $e', true);
    }
  }

  // === CÁC HÀM ĐỒNG BỘ STATE ===
  void addSavedJob(JobEntity job) {
    if (!_savedJobs.any((j) => j.jobId == job.jobId)) {
      _savedJobs.insert(0, job);
      notifyListeners();
    }
  }

  void removeSavedJob(int jobId) {
    _savedJobs.removeWhere((j) => j.jobId == jobId);
    notifyListeners();
  }
}