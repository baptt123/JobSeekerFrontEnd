import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/services/job_application_service.dart';

import '../../models/job-entity.dart';
import '../../services/job_service.dart';

class JobDetailViewModel extends ChangeNotifier {
  JobEntity? _job;
  JobEntity? get job => _job;
  JobApplicationService _jobApplicationService= JobApplicationService();
  JobService _jobService = JobService();
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  bool _isApplying = false;
  bool get isApplying => _isApplying;

  // ⭐️ THÊM: Biến lưu trạng thái đã nộp đơn
  // Chúng ta cần một biến riêng để có thể cập nhật nó ngay
  // sau khi apply thành công, mà không cần gọi lại API
  bool _isApplied = false;
  bool get isApplied => _isApplied;

  // Giả sử bạn có ApiService
  // final ApiService _apiService = ApiService();

  Future<void> fetchJobDetail(String jobTitle) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // API service sẽ fetch và parse JobEntity (đã có trường 'isApplied')
      _job = await _jobService.getJobDetail(jobTitle);

      // ⭐️ CẬP NHẬT: Lấy trạng thái 'isApplied' từ job vừa fetch
      if (_job != null) {
        _isApplied = _job!.isApplied;
      }

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> applyForJob(BuildContext context) async {
    // ⭐️ SỬA: Không cho apply nếu đang apply HOẶC đã apply rồi
    if (_isApplying || _isApplied) return;

    _isApplying = true;
    notifyListeners();

    try {
      // Gọi API để nộp đơn
      await _jobApplicationService.applyForJob(_job!.jobId);

      // ⭐️ CẬP NHẬT: Nếu API thành công, đổi trạng thái
      _isApplied = true;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nộp đơn thành công!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      // Xử lý lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Nộp đơn thất bại: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      _isApplying = false;
      notifyListeners();
    }
  }
}