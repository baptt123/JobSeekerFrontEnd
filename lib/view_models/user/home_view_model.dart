// lib/view_models/home_view_model.dart

import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/models/job-entity.dart';

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
  bool _hasMore = true; // Còn dữ liệu để tải
  bool _isLoadingMore = false; // Đang tải trang tiếp theo
  bool get isLoadingMore => _isLoadingMore;

  HomeViewModel() {
    fetchJobs(); // Tải trang đầu tiên
  }

  // Tải dữ liệu lần đầu hoặc làm mới
  Future<void> fetchJobs() async {
    _state = HomeState.loading;
    _currentPage = 1; // Reset về trang 1
    _jobs = [];       // Xóa danh sách cũ
    _hasMore = true;  // Đặt lại
    notifyListeners();

    try {
      final response = await _jobService.getAllJobs(page: _currentPage, limit: 10);
      _jobs = response.data;
      _hasMore = _currentPage < response.totalPages; // Kiểm tra còn trang không
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
    // Không tải nữa nếu đang tải hoặc đã hết dữ liệu
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners(); // Thông báo để UI có thể hiển thị loading...

    try {
      _currentPage++; // Tăng số trang
      final response = await _jobService.getAllJobs(page: _currentPage, limit: 10);

      _jobs.addAll(response.data); // Thêm dữ liệu mới vào danh sách
      _hasMore = _currentPage < response.totalPages; // Cập nhật lại
    } catch (e) {
      // Có thể xử lý lỗi tải thêm ở đây
      print('Error loading more jobs: $e');
      _currentPage--; // Quay lại trang trước nếu lỗi
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }
}