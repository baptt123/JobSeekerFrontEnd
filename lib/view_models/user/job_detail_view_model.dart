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

  // --- ⭐️ THÊM CÁC BIẾN TRẠNG THÁI MỚI ---
  bool _isApplying = false;
  bool get isApplying => _isApplying;

  String? _applyError;
  String? get applyError => _applyError;
  // --- KẾT THÚC THÊM MỚI ---

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

  // --- ⭐️ THÊM HÀM MỚI ĐỂ ỨNG TUYỂN ---
  Future<void> applyForJob(BuildContext context) async {
    // Không cho nhấn nếu đang apply hoặc job chưa tải xong
    if (_isApplying || _job == null) return;

    _isApplying = true;
    _applyError = null;
    notifyListeners(); // Báo cho UI biết là "đang apply"

    try {
      // Gọi service
      await _jobService.applyForJob(_job!.jobId);

      // "xuất thông báo đã ứng tuyển"
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ứng tuyển thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // Tắt loading và đóng trang chi tiết lại
      _isApplying = false;
      notifyListeners();
      Navigator.of(context).pop();

    } catch (e) {
      // Bắt lỗi từ service (ví dụ: "Đã ứng tuyển rồi", "Hết hạn")
      _applyError = e.toString().replaceFirst('Exception: ', '');
      _isApplying = false;
      notifyListeners(); // Tắt loading

      // Hiển thị lỗi cho người dùng
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_applyError ?? 'Có lỗi xảy ra'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}