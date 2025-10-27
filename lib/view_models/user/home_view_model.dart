// lib/view_models/home_view_model.dart

import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/models/job-entity.dart';
// Import DTO mới

import '../../dto/filter_job_dto.dart';
import '../../services/job_service.dart';

enum HomeState { idle, loading, success, error }

class HomeViewModel extends ChangeNotifier {
  final JobService _jobService = JobService();

  List<JobEntity> _jobs = [];
  List<JobEntity> get jobs => _jobs;

  HomeState _state = HomeState.idle;
  HomeState get state => _state;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Biến cho phân trang
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  // ---- BIẾN MỚI CHO FILTER ----
  FilterJobDto _currentFilter = FilterJobDto(); // Giữ filter đang áp dụng
  FilterJobDto get currentFilter => _currentFilter;
  bool _isFiltered = false; // Trạng thái đang lọc
  bool get isFiltered => _isFiltered;
  // -----------------------------

  HomeViewModel() {
    fetchJobs(); // Tải trang đầu tiên
  }

  // Tải dữ liệu lần đầu HOẶC "XÓA BỘ LỌC"
  Future<void> fetchJobs() async {
    _state = HomeState.loading;
    _currentPage = 1;
    _jobs = [];
    _hasMore = true;

    // ---- RESET TRẠNG THÁI FILTER ----
    _isFiltered = false;
    _currentFilter = FilterJobDto();
    // ---------------------------------

    notifyListeners();

    try {
      // Gọi lại hàm getAllJobs (có phân trang)
      final response = await _jobService.getAllJobs(page: _currentPage, limit: 10);
      _jobs = response.data;
      _hasMore = _currentPage < response.totalPages;
      _state = HomeState.success;
    } catch (e) {
      _state = HomeState.error;
      _errorMessage = e.toString();
    } finally {
      notifyListeners();
    }
  }

  // Tải thêm dữ liệu khi cuộn
  Future<void> fetchMoreJobs() async {
    // ---- KIỂM TRA ĐIỀU KIỆN MỚI ----
    // Không tải nữa nếu đang tải, hết dữ liệu, HOẶC ĐANG LỌC
    // (Vì API filter của bạn không hỗ trợ phân trang)
    if (_isLoadingMore || !_hasMore || _isFiltered) return;
    // ----------------------------------

    _isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;
      // Luôn gọi getAllJobs vì chỉ fetchMore khi không lọc
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

  // ---- HÀM MỚI ĐỂ ÁP DỤNG BỘ LỌC ----
  Future<void> applyFilter(FilterJobDto dto) async {
    _state = HomeState.loading;
    _jobs = [];
    _currentFilter = dto; // Lưu lại filter
    _isFiltered = true;   // Đặt trạng thái đang lọc
    _hasMore = false;     // TẮT phân trang
    _isLoadingMore = false;
    _currentPage = 1;     // Reset
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
}