import 'package:flutter/material.dart';

import '../../models/job-entity.dart';
import '../../services/job_service.dart';

class JobDetailViewModel extends ChangeNotifier {
  final JobService _jobService = JobService();

  JobEntity? _job;
  JobEntity? get job => _job;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool get hasError => _errorMessage != null;

  /// Hàm chính để gọi API lấy chi tiết công việc
  Future<void> fetchJobDetail(String title) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Thông báo cho UI "đang tải"

    try {
      // Gọi service
      _job = await _jobService.getJobDetail(title);
    } catch (e) {
      // Bắt lỗi
      _errorMessage = e.toString();
    } finally {
      // Dù thành công hay thất bại, cũng tắt loading
      _isLoading = false;
      notifyListeners(); // Cập nhật UI với data hoặc lỗi
    }
  }
}