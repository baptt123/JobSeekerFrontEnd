import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:job_seeker_frontend/models/job-entity.dart';
import 'package:job_seeker_frontend/models/user-entity.dart';
import 'package:job_seeker_frontend/services/user_service.dart';
import 'package:job_seeker_frontend/view_models/user/save_job_view_model.dart';

import '../../dto/filter_job_dto.dart';
import '../../dto/pagination_job_response_dto.dart';
import '../../services/job_service.dart';

// Thêm trạng thái 'loadingMore' để hiển thị spinner nhỏ khi lướt xuống đáy
enum HomeState { idle, loading, loadingMore, success, error }

class HomeViewModel extends ChangeNotifier {
  // --- SERVICES ---
  final JobService _jobService = JobService();
  final UserService _userService = UserService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // --- STATE VARIABLES ---
  List<JobEntity> _jobs = [];
  List<JobEntity> get jobs => _jobs;

  HomeState _state = HomeState.idle;
  HomeState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Phân trang
  int _currentPage = 1;
  int _totalPages = 1;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  // Bộ lọc
  FilterJobDto _currentFilter = FilterJobDto();
  FilterJobDto get currentFilter => _currentFilter;
  bool _isFiltered = false;
  bool get isFiltered => _isFiltered;

  // Chế độ hiển thị (User vs Guest)
  bool _isRecommendedMode = false;
  bool get isRecommendedMode => _isRecommendedMode;

  // Email người dùng (để hiển thị trên Header)
  String _currentEmail = "Guest";
  String get currentEmail => _currentEmail;

  // Quản lý ID các job đã lưu (để hiển thị icon bookmark)
  Set<int> _savedJobIds = {};

  bool isJobSaved(int jobId) {
    return _savedJobIds.contains(jobId);
  }

  // --- CONSTRUCTOR ---
  HomeViewModel() {
    fetchInitialData();
  }

  // ========================================================================
  // 1. TẢI DỮ LIỆU BAN ĐẦU (LOGIC CHÍNH)
  // ========================================================================
  Future<void> fetchInitialData() async {
    _state = HomeState.loading;
    _currentPage = 1;
    _jobs = []; // Reset danh sách
    _isFiltered = false;
    _currentFilter = FilterJobDto();
    notifyListeners();

    try {
      final token = await _storage.read(key: 'accessToken');
      final bool isLoggedIn = token != null;

      if (isLoggedIn) {
        // === TRƯỜNG HỢP A: ĐÃ ĐĂNG NHẬP ===
        try {
          _isRecommendedMode = true;

          // Gọi song song 3 API: Job gợi ý, Job đã lưu, Profile User
          final results = await Future.wait([
            _jobService.getRecommendedJobs(),
            _jobService.getSavedJobs(),
            _userService.getUserProfile(),
          ]);

          // 1. Xử lý List Job gợi ý
          _jobs = results[0] as List<JobEntity>;
          // API gợi ý thường trả về list cố định, không phân trang -> set mặc định
          _currentPage = 1;
          _totalPages = 1;

          // 2. Xử lý List Job đã lưu -> lấy ID để check bookmark
          final savedJobs = results[1] as List<JobEntity>;
          _savedJobIds = savedJobs.map((job) => job.jobId).toSet();

          // 3. Xử lý Profile User -> lấy email hiển thị header
          final userProfile = results[2] as UserEntity;
          _currentEmail = userProfile.email; // Hoặc userProfile.fullName

          _state = HomeState.success;
        } catch (e) {
          // 🔥 FIX LỖI 401: Nếu token lỗi/hết hạn -> Tự động Logout về Guest
          print("⚠️ Lỗi tải dữ liệu User (có thể do token hết hạn): $e");
          await logout(); // Chuyển về chế độ khách
          return; // Dừng hàm, logout() sẽ tự gọi lại fetchInitialData
        }
      } else {
        // === TRƯỜNG HỢP B: KHÁCH (GUEST) ===
        _isRecommendedMode = false;
        _savedJobIds = {}; // Khách không có danh sách lưu
        _currentEmail = "Guest";

        final response = await _jobService.getAllJobs(page: 1, limit: 10);
        _jobs = response.data;
        _currentPage = response.page;
        _totalPages = response.totalPages;

        _state = HomeState.success;
      }
    } catch (e) {
      _state = HomeState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // ========================================================================
  // 2. TẢI THÊM (LOAD MORE / INFINITE SCROLL)
  // ========================================================================
  Future<void> loadMoreJobs() async {
    // Điều kiện dừng: Đang tải, Hết trang, hoặc Đang ở chế độ Gợi ý (User)
    if (_state == HomeState.loadingMore ||
        _state == HomeState.loading ||
        _currentPage >= _totalPages ||
        _isRecommendedMode) {
      return;
    }

    _state = HomeState.loadingMore;
    notifyListeners(); // Cập nhật UI để hiện spinner nhỏ ở dưới

    try {
      final nextPage = _currentPage + 1;
      PaginatedJobsResponse? response;

      if (_isFiltered) {
        // Nếu API Filter hỗ trợ phân trang thì gọi ở đây
        // Hiện tại giả định dùng getAllJobs
      } else {
        response = await _jobService.getAllJobs(page: nextPage, limit: 10);
      }

      if (response != null) {
        // Nối thêm dữ liệu mới vào danh sách cũ
        _jobs.addAll(response.data);
        _currentPage = response.page;
        _totalPages = response.totalPages;
      }

      _state = HomeState.success;
    } catch (e) {
      // Nếu lỗi load more, chỉ hiện thông báo nhỏ, không thay đổi state chính thành error
      print("Lỗi tải thêm: $e");
      // Có thể set _state = HomeState.success để tắt spinner
      _state = HomeState.success;
    } finally {
      notifyListeners();
    }
  }

  // ========================================================================
  // 3. ĐĂNG XUẤT (LOGOUT)
  // ========================================================================
  Future<void> logout() async {
    _state = HomeState.loading;
    notifyListeners();

    // 1. Xóa sạch token
    await _storage.deleteAll();

    // 2. Reset các biến trạng thái về mặc định
    _isRecommendedMode = false;
    _savedJobIds.clear();
    _currentEmail = "Guest";
    _jobs = [];

    // 3. Tải lại dữ liệu (Lúc này sẽ vào nhánh Guest)
    await fetchInitialData();
  }

  // ========================================================================
  // 4. LỌC CÔNG VIỆC (FILTER)
  // ========================================================================
  Future<void> applyFilter(FilterJobDto dto) async {
    _state = HomeState.loading;
    _jobs = [];
    _currentFilter = dto;
    _isFiltered = true;
    _isRecommendedMode = false; // Khi lọc thì tắt chế độ gợi ý

    // Reset phân trang
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

  // ========================================================================
  // 5. LƯU / BỎ LƯU JOB (TOGGLE SAVE)
  // ========================================================================
  Future<void> toggleSaveJob(
      JobEntity job,
      BuildContext context,
      SavedJobsViewModel savedJobsViewModel,
      ) async {
    // Hàm hiển thị thông báo nhanh
    void _showSnackbar(String message, bool isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
          duration: const Duration(seconds: 1),
        ),
      );
    }

    // Kiểm tra đăng nhập
    if (!_isRecommendedMode) {
      // Kiểm tra kỹ hơn bằng token
      final token = await _storage.read(key: 'accessToken');
      if (token == null) {
        _showSnackbar('Vui lòng đăng nhập để lưu công việc', true);
        // Có thể điều hướng sang trang login tại đây nếu muốn
        return;
      }
    }

    try {
      final jobId = job.jobId;

      if (isJobSaved(jobId)) {
        // === HỦY LƯU ===
        await _jobService.unsaveJob(jobId);

        // Cập nhật Local State
        _savedJobIds.remove(jobId);

        // Đồng bộ với ViewModel màn hình Saved Jobs
        savedJobsViewModel.removeSavedJob(jobId);

        _showSnackbar('Đã bỏ lưu công việc', false);
      } else {
        // === LƯU ===
        await _jobService.saveJob(jobId);

        // Cập nhật Local State
        _savedJobIds.add(jobId);

        // Đồng bộ với ViewModel màn hình Saved Jobs
        savedJobsViewModel.addSavedJob(job);

        _showSnackbar('Đã lưu công việc thành công', false);
      }
      notifyListeners(); // Cập nhật UI (icon bookmark)
    } catch (e) {
      // Nếu lỗi 401 khi lưu -> Token hết hạn -> Logout
      if (e.toString().contains('401')) {
        await logout();
        _showSnackbar('Phiên đăng nhập hết hạn, vui lòng đăng nhập lại', true);
      } else {
        _showSnackbar('Lỗi: $e', true);
      }
    }
  }

  // ========================================================================
  // 6. HELPER METHODS (Dùng để đồng bộ từ các màn hình khác)
  // ========================================================================

  // Được gọi khi user bỏ lưu ở màn hình SavedJobsScreen
  void removeSavedId(int jobId) {
    _savedJobIds.remove(jobId);
    notifyListeners();
  }

  // Được gọi khi user lưu ở màn hình JobDetailScreen
  void addSavedId(int jobId) {
    _savedJobIds.add(jobId);
    notifyListeners();
  }

  // Refresh dữ liệu
  Future<void> fetchJobs() async {
    await fetchInitialData();
  }
}