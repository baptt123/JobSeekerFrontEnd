// lib/view_models/user/home_view_model.dart

import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/models/job-entity.dart';
import 'package:job_seeker_frontend/view_models/user/save_job_view_model.dart';
// Import DTO mới
import '../../dto/filter_job_dto.dart';
import '../../dto/pagination_job_response_dto.dart';
import '../../services/job_service.dart';
// ++ THÊM IMPORT ĐỂ ĐỒNG BỘ STATE

enum HomeState { idle, loading, success, error }

class HomeViewModel extends ChangeNotifier {
  final JobService _jobService = JobService();

  List<JobEntity> _jobs = [];
  List<JobEntity> get jobs => _jobs;

  HomeState _state = HomeState.idle;
  HomeState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // ✅ 1. THAY ĐỔI STATE TỪ INFINITE SCROLL SANG PAGINATION
  int _currentPage = 1;
  int _totalPages = 1;

  // ✅ 2. THÊM GETTER CHO VIEW SỬ DỤNG
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;

  FilterJobDto _currentFilter = FilterJobDto();
  FilterJobDto get currentFilter => _currentFilter;
  bool _isFiltered = false;
  bool get isFiltered => _isFiltered;

  // ++++ LOGIC LƯU JOB MỚI ++++
  Set<int> _savedJobIds = {};

  bool isJobSaved(int jobId) {
    return _savedJobIds.contains(jobId);
  }
  // ++++++++++++++++++++++++++++

  HomeViewModel() {
    fetchInitialData();
  }

  Future<void> fetchInitialData() async {
    _state = HomeState.loading;
    _currentPage = 1;
    _jobs = [];
    _isFiltered = false;
    _currentFilter = FilterJobDto();
    notifyListeners();

    try {
      final results = await Future.wait([
        _jobService.getAllJobs(page: _currentPage, limit: 10),
        _jobService.getSavedJobs(),
      ]);

      // Xử lý kết quả getAllJobs
      final response = results[0] as PaginatedJobsResponse;
      _jobs = response.data;

      // ✅ 3. LƯU STATE PHÂN TRANG TỪ API
      _currentPage = response.page;
      _totalPages = response.totalPages;

      // Xử lý kết quả getSavedJobs
      final savedJobs = results[1] as List<JobEntity>;
      _savedJobIds = savedJobs.map((job) => job.jobId).toSet();

      _state = HomeState.success;
    } catch (e) {
      _state = HomeState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Tải lại trang 1 (hoặc "Xóa bộ lọc")
  Future<void> fetchJobs() async {
    _state = HomeState.loading;
    _currentPage = 1; // Luôn reset về trang 1
    _jobs = [];
    _isFiltered = false;
    _currentFilter = FilterJobDto();
    notifyListeners();

    try {
      final response = await _jobService.getAllJobs(page: _currentPage, limit: 10);
      _jobs = response.data;

      // ✅ 4. LƯU STATE PHÂN TRANG TỪ API
      _currentPage = response.page;
      _totalPages = response.totalPages;

      // ++ LUÔN CẬP NHẬT LẠI SAVED IDS KHI RESET ++
      final savedJobs = await _jobService.getSavedJobs();
      _savedJobIds = savedJobs.map((job) => job.jobId).toSet();

      _state = HomeState.success;
    } catch (e) {
      _state = HomeState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // ✅ 6. HÀM MỚI ĐỂ CHUYỂN TRANG
  Future<void> goToPage(int page) async {
    // Không làm gì nếu đang tải hoặc chọn đúng trang hiện tại
    if (_state == HomeState.loading || page == _currentPage) return;

    // Không cho phép đi ra ngoài tổng số trang
    if (page < 1 || page > _totalPages) return;

    _state = HomeState.loading;
    notifyListeners(); // Hiển thị loading overlay

    try {
      final response = await _jobService.getAllJobs(page: page, limit: 10);
      _jobs = response.data; // Thay thế danh sách jobs cũ
      _currentPage = response.page;
      _totalPages = response.totalPages;
      _state = HomeState.success;
    } catch (e) {
      _state = HomeState.error;
      _errorMessage = e.toString();
      // Nếu lỗi, state sẽ là error nhưng không đổi trang
      _state = HomeState.error;
    } finally {
      notifyListeners();
    }
  }

  // Áp dụng bộ lọc
  Future<void> applyFilter(FilterJobDto dto) async {
    _state = HomeState.loading;
    _jobs = [];
    _currentFilter = dto;
    _isFiltered = true;

    // ✅ 7. RESET STATE PHÂN TRANG KHI LỌC
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

  // ++ HÀM XỬ LÝ LƯU/XÓA (Giữ nguyên) ++
  Future<void> toggleSaveJob(
      JobEntity job,
      BuildContext context,
      SavedJobsViewModel savedJobsViewModel,
      ) async {
    // ... (Giữ nguyên code của bạn) ...
    // Hàm tiện ích hiển thị snackbar
    void _showSnackbar(String message, bool isError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.red : Colors.green,
        ),
      );
    }

    try {
      final jobId = job.jobId;
      if (isJobSaved(jobId)) {
        // === HỦY LƯU JOB ===
        await _jobService.unsaveJob(jobId);
        _savedJobIds.remove(jobId);
        // Đồng bộ với SavedJobsViewModel
        savedJobsViewModel.removeSavedJob(jobId);
        _showSnackbar('Đã xóa job thành công', false);
      } else {
        // === LƯU JOB ===
        await _jobService.saveJob(jobId);
        _savedJobIds.add(jobId);
        // Đồng bộ với SavedJobsViewModel
        savedJobsViewModel.addSavedJob(job);
        _showSnackbar('Đã lưu job thành công', false);
      }
      notifyListeners(); // Cập nhật icon bookmark ở Home
    } catch (e) {
      _showSnackbar('Đã xảy ra lỗi: $e', true);
    }
  }

  // ++ HÀM ĐỒNG BỘ ++

  // Hàm này đã có trong file của bạn
  void removeSavedId(int jobId) {
    _savedJobIds.remove(jobId);
    notifyListeners();
  }

  // ⭐️⭐️⭐️ HÀM CÒN THIẾU ĐÂY ⭐️⭐️⭐️
  // (Được gọi bởi JobDetailViewModel để đồng bộ khi lưu job)
  void addSavedId(int jobId) {
    _savedJobIds.add(jobId);
    notifyListeners();
  }
// ⭐️⭐️⭐️ KẾT THÚC HÀM MỚI ⭐️⭐️⭐️
}