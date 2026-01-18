import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:job_seeker_frontend/models/job-entity.dart';
import 'package:job_seeker_frontend/models/user-entity.dart';
import 'package:job_seeker_frontend/services/user_service.dart';
import 'package:job_seeker_frontend/view_models/user/save_job_view_model.dart';
import '../../dto/filter_job_dto.dart';
import '../../services/job_service.dart';

enum HomeState { idle, loading, loadingMore, success, error }

class HomeViewModel extends ChangeNotifier {
  final JobService _jobService = JobService();
  final UserService _userService = UserService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<JobEntity> _jobs = [];
  List<JobEntity> get jobs => _jobs;

  List<JobEntity> _randomJobs = [];
  List<JobEntity> get randomJobs => _randomJobs;

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

  // Flag kiểm tra xem có đang ở chế độ gợi ý hay không
  bool _isRecommendedMode = false;
  bool get isRecommendedMode => _isRecommendedMode;

  UserEntity? _currentUser;
  UserEntity? get currentUser => _currentUser;

  Set<int> _savedJobIds = {};
  bool isJobSaved(int jobId) => _savedJobIds.contains(jobId);

  HomeViewModel() {
    // Không gọi fetchInitialData() ở đây để tránh gọi nhiều lần khi UI chưa build xong
  }

  Future<void> refreshJobs() async {
    await fetchInitialData();
  }

  // [UPDATED] Hàm khởi tạo dữ liệu chính với logic gợi ý chạy ngầm
  Future<void> fetchInitialData() async {
    _state = HomeState.loading;
    _currentPage = 1;
    _jobs = [];
    _isFiltered = false;
    _currentFilter = FilterJobDto();
    _isRecommendedMode = false;
    _errorMessage = null;
    notifyListeners();

    // 1. Luôn tải danh sách random jobs cho banner (chạy song song)
    _fetchRandomJobs();

    try {
      final token = await _storage.read(key: 'accessToken');
      final bool isLoggedIn = token != null;

      if (isLoggedIn) {
        // --- LOGIC CHO NGƯỜI DÙNG ĐÃ ĐĂNG NHẬP ---
        try {
          final userProfile = await _userService.getUserProfile();
          final savedJobs = await _jobService.getSavedJobs();

          _currentUser = userProfile;
          _savedJobIds = savedJobs.map((job) => job.jobId).toSet();

          // [QUAN TRỌNG] Gọi API gợi ý dựa trên lịch sử lưu (Saved Jobs)
          // Backend sẽ trả về list rỗng nếu user chưa lưu job nào hoặc AI không tìm thấy
          final recommendedList = await _jobService.getRecommendedJobsByHistory();

          if (recommendedList.isNotEmpty) {
            // Case 1: Có dữ liệu gợi ý -> Hiển thị chế độ gợi ý
            _jobs = recommendedList;
            _isRecommendedMode = true;
            _state = HomeState.success;
          } else {
            // Case 2: Không có gợi ý (hoặc list rỗng) -> Fallback về Load tất cả việc làm
            _isRecommendedMode = false;
            await _loadAllJobs();
          }

        } catch (e) {
          // Nếu lỗi xác thực user -> Logout mềm và load dữ liệu khách
          print("Lỗi session user: $e");
          await logout();
          return;
        }
      } else {
        // --- LOGIC CHO KHÁCH (GUEST) ---
        await _loadGuestData();
      }
    } catch (e) {
      _state = HomeState.error;
      _errorMessage = "Không thể kết nối đến máy chủ. Vui lòng thử lại.";
    } finally {
      notifyListeners();
    }
  }

  Future<void> _fetchRandomJobs() async {
    try {
      final jobs = await _jobService.getRandomJobs();
      _randomJobs = jobs;
      notifyListeners();
    } catch (e) {
      print('Lỗi tải banner random: $e');
    }
  }

  Future<void> _loadGuestData() async {
    _isRecommendedMode = false;
    _savedJobIds = {};
    _currentUser = null;
    await _loadAllJobs();
  }

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
      throw e; // Ném tiếp để catch bên ngoài xử lý
    }
  }

  Future<void> loadMoreJobs() async {
    // Nếu đang ở chế độ Gợi ý hoặc Filter, ta tạm thời không load more
    // (Vì API gợi ý hiện tại trả về list cố định, chưa phân trang sâu)
    if (_state == HomeState.loadingMore ||
        _state == HomeState.loading ||
        _currentPage >= _totalPages ||
        _isRecommendedMode ||
        _isFiltered) return;

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
      _state = HomeState.success; // Fail silently
    } finally {
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _state = HomeState.loading;
    notifyListeners();
    await _storage.deleteAll();
    await _loadGuestData();
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
    final token = await _storage.read(key: 'accessToken');
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập để lưu'), backgroundColor: Colors.redAccent));
      return;
    }

    try {
      final jobId = job.jobId;
      if (isJobSaved(jobId)) {
        await _jobService.unsaveJob(jobId);
        _savedJobIds.remove(jobId);
        savedJobsViewModel.removeSavedJob(jobId);
      } else {
        await _jobService.saveJob(jobId);
        _savedJobIds.add(jobId);
        savedJobsViewModel.addSavedJob(job);
      }
      notifyListeners();
    } catch (e) {
      if (e.toString().contains('401')) await logout();
    }
  }

  void removeSavedId(int jobId) { _savedJobIds.remove(jobId); notifyListeners(); }
  void addSavedId(int jobId) { _savedJobIds.add(jobId); notifyListeners(); }
  Future<void> fetchJobs() async { await fetchInitialData(); }
}