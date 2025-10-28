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

  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  FilterJobDto _currentFilter = FilterJobDto();
  FilterJobDto get currentFilter => _currentFilter;
  bool _isFiltered = false;
  bool get isFiltered => _isFiltered;

  // ++++ LOGIC LƯU JOB MỚI ++++
  Set<int> _savedJobIds = {};

  // Hàm helper để UI kiểm tra
  bool isJobSaved(int jobId) {
    return _savedJobIds.contains(jobId);
  }
  // ++++++++++++++++++++++++++++

  HomeViewModel() {
    // Đổi tên hàm khởi tạo để tải cả job và saved-list
    fetchInitialData();
  }

  // ++ HÀM MỚI: Tải dữ liệu lần đầu ++
  Future<void> fetchInitialData() async {
    _state = HomeState.loading;
    _currentPage = 1;
    _jobs = [];
    _hasMore = true;
    _isFiltered = false;
    _currentFilter = FilterJobDto();
    notifyListeners();

    try {
      // Tải song song danh sách job và danh sách đã lưu
      final results = await Future.wait([
        _jobService.getAllJobs(page: _currentPage, limit: 10),
        _jobService.getSavedJobs(),
      ]);

      // Xử lý kết quả getAllJobs
      final response = results[0] as PaginatedJobsResponse;
      _jobs = response.data;
      _hasMore = _currentPage < response.totalPages;

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

  // Tải dữ liệu lần đầu HOẶC "XÓA BỘ LỌC"
  Future<void> fetchJobs() async {
    _state = HomeState.loading;
    _currentPage = 1;
    _jobs = [];
    _hasMore = true;
    _isFiltered = false;
    _currentFilter = FilterJobDto();
    notifyListeners();

    try {
      // Vẫn gọi lại hàm getAllJobs
      final response = await _jobService.getAllJobs(page: _currentPage, limit: 10);
      _jobs = response.data;
      _hasMore = _currentPage < response.totalPages;

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

  // Tải thêm dữ liệu khi cuộn (Giữ nguyên logic của bạn)
  Future<void> fetchMoreJobs() async {
    if (_isLoadingMore || !_hasMore || _isFiltered) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      _currentPage++;
      final response = await _jobService.getAllJobs(page: _currentPage, limit: 10);
      _jobs.addAll(response.data);
      _hasMore = _currentPage < response.totalPages;
    } catch (e) {
      print('Error loading more jobs: $e');
      _currentPage--;
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  // Áp dụng bộ lọc (Gần như giữ nguyên, chỉ không reset savedJobIds)
  Future<void> applyFilter(FilterJobDto dto) async {
    _state = HomeState.loading;
    _jobs = [];
    _currentFilter = dto;
    _isFiltered = true;
    _hasMore = false;
    _isLoadingMore = false;
    _currentPage = 1;
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

  // ++ HÀM MỚI ĐỂ XỬ LÝ LƯU/XÓA ++
  Future<void> toggleSaveJob(
      JobEntity job,
      BuildContext context,
      SavedJobsViewModel savedJobsViewModel,
      ) async {
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

  // ++ HÀM MỚI: Nhận đồng bộ từ SavedJobsViewModel ++
  void removeSavedId(int jobId) {
    _savedJobIds.remove(jobId);
    notifyListeners();
  }
}