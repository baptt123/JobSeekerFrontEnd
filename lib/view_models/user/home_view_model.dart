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
          _isRecommendedMode = true;
          // Gọi API
          final results = await Future.wait([
            _jobService.getRecommendedJobs(),
            _jobService.getSavedJobs(),
            _userService.getUserProfile(),
          ]);

          _jobs = results[0] as List<JobEntity>;
          final savedJobs = results[1] as List<JobEntity>;
          _savedJobIds = savedJobs.map((job) => job.jobId).toSet();
          _currentUser = results[2] as UserEntity;

          _state = HomeState.success;
        } catch (e) {
          print("Lỗi khi tải dữ liệu User: $e");
          // 🔥 FIX QUAN TRỌNG: Nếu lỗi bất kỳ khi đang ở chế độ User -> Logout về Guest ngay
          // Để tránh hiện màn hình lỗi
          await logout();
          return;
        }
      } else {
        await _loadGuestData();
      }
    } catch (e) {
      // Nếu lỗi quá nặng (ví dụ mất mạng hoàn toàn) mới hiện lỗi
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

  Future<void> toggleSaveJob(JobEntity job, BuildContext context, SavedJobsViewModel savedJobsViewModel) async {
    void _showSnackbar(String message) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 1)));
    }
    if (!_isRecommendedMode) {
      _showSnackbar('Vui lòng đăng nhập để lưu công việc');
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
        _showSnackbar('Phiên đăng nhập hết hạn');
      } else {
        _showSnackbar('Lỗi: $e');
      }
    }
  }
  void removeSavedId(int jobId) { _savedJobIds.remove(jobId); notifyListeners(); }
  void addSavedId(int jobId) { _savedJobIds.add(jobId); notifyListeners(); }
  Future<void> fetchJobs() async { await fetchInitialData(); }
}