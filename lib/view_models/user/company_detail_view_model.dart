// lib/view_models/user/company_detail_view_model.dart

import 'package:flutter/material.dart';
import '../../models/company-entity.dart';
import '../../models/job-entity.dart';
import '../../services/job_service.dart';

class CompanyDetailViewModel extends ChangeNotifier {
  final JobService _jobService = JobService();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  // [THÊM] Biến lưu thông báo lỗi
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CompanyEntity? _company;
  CompanyEntity? get company => _company;

  List<JobEntity> _jobs = [];
  List<JobEntity> get jobs => _jobs;

  Future<void> fetchCompanyData(int companyId) async {
    _isLoading = true;
    _errorMessage = null; // Reset lỗi trước khi gọi mới
    notifyListeners();

    try {
      final data = await _jobService.getCompanyWithJobs(companyId);

      if (data.isNotEmpty) {
        if (data['company'] != null) {
          _company = CompanyEntity.fromJson(data['company']);
        }
        if (data['jobs'] != null) {
          _jobs = (data['jobs'] as List)
              .map((e) => JobEntity.fromJson(e))
              .toList();
        }
      } else {
        _errorMessage = "Không tìm thấy dữ liệu công ty.";
      }
    } catch (e) {
      // Bắt lỗi và lưu vào biến
      _errorMessage = "Lỗi kết nối: ${e.toString().replaceAll('Exception:', '')}";
      print("Lỗi fetchCompanyData: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}