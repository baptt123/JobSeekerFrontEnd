import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:job_seeker_frontend/models/job-entity.dart';
import 'package:job_seeker_frontend/models/user-entity.dart';
import 'package:job_seeker_frontend/services/user_service.dart';
import 'package:job_seeker_frontend/view_models/user/save_job_view_model.dart';
import '../../dto/filter_job_dto.dart';
import '../../dto/pagination_job_response_dto.dart';
import '../../services/job_service.dart';

enum HomeState { idle, loading, loadingMore, success, error }

class HomeViewModel extends ChangeNotifier {
  final JobService _jobService = JobService();
  final UserService _userService = UserService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<JobEntity> _jobs = [];
  List<JobEntity> get jobs => _jobs;

  HomeState _state = HomeState.idle;
  HomeState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  int _currentPage = 1;
  int _totalPages = 1;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  FilterJobDto _currentFilter = FilterJobDto();
  FilterJobDto get currentFilter => _currentFilter;
  bool _isFiltered = false;
  bool get isFiltered => _isFiltered;

  bool _isRecommendedMode = false;
  bool get isRecommendedMode => _isRecommendedMode;

  UserEntity? _currentUser;
  UserEntity? get currentUser => _currentUser;

  Set<int> _savedJobIds = {};
  bool isJobSaved(int jobId) => _savedJobIds.contains(jobId);

  HomeViewModel() {
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    _state = HomeState.loading;
    _currentPage = 1;
    _jobs = [];
    _isFiltered = false;
    _currentFilter = FilterJobDto();
    _currentUser = null;
    notifyListeners();

    try {
      final token = await _storage.read(key: 'accessToken');
      final bool isLoggedIn = token != null;

      if (isLoggedIn) {
        try {
          // Gọi API lấy User Profile & Saved Jobs trước
          final userProfile = await _userService.getUserProfile();
          final savedJobs = await _jobService.getSavedJobs();

          _currentUser = userProfile;
          _savedJobIds = savedJobs.map((job) => job.jobId).toSet();

          // Gọi API Recommended
          final recommendedJobs = await _jobService.getRecommendedJobs();

          if (recommendedJobs.isNotEmpty) {
            _jobs = recommendedJobs;
            _isRecommendedMode = true; // Chỉ bật chế độ này nếu CÓ kết quả gợi ý
          } else {
            // Nếu không có gợi ý (do chưa có CV hoặc không khớp), chuyển về chế độ thường
            _isRecommendedMode = false;
            await _loadAllJobs(); // Load job mới nhất bình thường
          }

          _state = HomeState.success;
        } catch (e) {
          // Nếu token lỗi, logout và load guest data
          await logout();
          return;
        }
      } else {
        await _loadGuestData();
      }
    } catch (e) {
      _state = HomeState.error;
      _errorMessage = "Không thể kết nối đến máy chủ.";
    } finally {
      notifyListeners();
    }
  }

  // Tách hàm load guest ra cho gọn
  Future<void> _loadGuestData() async {
    _isRecommendedMode = false;
    _savedJobIds = {};
    _currentUser = null;
    await _loadAllJobs();
  }

  // Hàm load job chung (phân trang)
  Future<void> _loadAllJobs() async {
    try {
      final response = await _jobService.getAllJobs(page: 1, limit: 10);
      _jobs = response.data;
      _currentPage = response.page;
      _totalPages = response.totalPages;
      _state = HomeState.success;
    } catch (e) {
      _state = HomeState.error;
      _errorMessage = e.toString();
    }
  }

  Future<void> loadMoreJobs() async {
    if (_state == HomeState.loadingMore || _state == HomeState.loading || _currentPage >= _totalPages || _isRecommendedMode) return;
    _state = HomeState.loadingMore;
    notifyListeners();
    try {
      final nextPage = _currentPage + 1;
      final response = await _jobService.getAllJobs(page: nextPage, limit: 10);
      _jobs.addAll(response.data);
      _currentPage = response.page;
      _totalPages = response.totalPages;
      _state = HomeState.success;
    } catch (e) {
      _state = HomeState.success;
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _state = HomeState.loading;
    notifyListeners();
    await _storage.deleteAll();
    await _loadGuestData(); // Chuyển về guest data
    notifyListeners();
  }

  Future<void> applyFilter(FilterJobDto dto) async {
    _state = HomeState.loading;
    _jobs = [];
    _currentFilter = dto;
    _isFiltered = true;
    _isRecommendedMode = false;
    _currentPage = 1;
    _totalPages = 1;
    notifyListeners();
    try {
      final result = await _jobService.filterJobs(_currentFilter);
      _jobs = result;
      _state = HomeState.success;
    } catch (e) {
      _state = HomeState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // ✅ ĐÃ SỬA: Logic Toggle Save Job
  Future<void> toggleSaveJob(JobEntity job, BuildContext context, SavedJobsViewModel savedJobsViewModel) async {
    void _showSnackbar(String message, {bool isError = false}) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: isError ? Colors.redAccent : Colors.green,
              duration: const Duration(seconds: 1),
            )
        );
      }
    }

    // 1. Kiểm tra Token thật sự
    final token = await _storage.read(key: 'accessToken');
    if (token == null) {
      _showSnackbar('Vui lòng đăng nhập để lưu công việc', isError: true);
      // Có thể chuyển hướng sang Login nếu muốn
      // Navigator.pushNamed(context, '/login');
      return;
    }

    try {
      final jobId = job.jobId;
      if (isJobSaved(jobId)) {
        await _jobService.unsaveJob(jobId);
        _savedJobIds.remove(jobId);
        savedJobsViewModel.removeSavedJob(jobId);
        _showSnackbar('Đã bỏ lưu');
      } else {
        await _jobService.saveJob(jobId);
        _savedJobIds.add(jobId);
        savedJobsViewModel.addSavedJob(job);
        _showSnackbar('Đã lưu tin');
      }
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('401')) {
        await logout();
        _showSnackbar('Phiên đăng nhập hết hạn', isError: true);
      } else {
        _showSnackbar('Lỗi: $e', isError: true);
      }
    }
  }

  void removeSavedId(int jobId) { _savedJobIds.remove(jobId); notifyListeners(); }
  void addSavedId(int jobId) { _savedJobIds.add(jobId); notifyListeners(); }
  Future<void> fetchJobs() async { await fetchInitialData(); }
}