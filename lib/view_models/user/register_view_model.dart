// lib/viewmodels/register_viewmodel.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/dto/register_dto.dart'; // Giữ nguyên import của bạn
import 'package:job_seeker_frontend/services/register_service.dart'; // Giữ nguyên import của bạn

class RegisterViewModel extends ChangeNotifier {
  final RegisterService _registerService = RegisterService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

// lib/viewmodels/register_view_model.dart

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _isSuccess = false;
    notifyListeners();

    try {
      final registerData = RegisterDTO(
        fullName: fullName,
        email: email,
        password: password,
      );

      final response = await _registerService.register(registerData);

      if (response.statusCode == 201) {
        _isSuccess = true;
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        final responseData = e.response!.data as Map<String, dynamic>;

        // Lấy giá trị của key 'message' ở cấp ngoài cùng
        final messageValue = responseData['message'];

        // ======================= PHẦN SỬA LỖI CHÍNH =======================
        if (messageValue is Map) {
          // TRƯỜNG HỢP 1: `message` là một object (như lỗi email tồn tại)
          // Truy cập vào key 'message' bên trong object đó
          _errorMessage = messageValue['message'] as String?;
        } else if (messageValue is List) {
          // TRƯỜNG HỢP 2: `message` là một danh sách (lỗi validation từ Pipe)
          _errorMessage = messageValue.join('\n');
        } else if (messageValue is String) {
          // TRƯỜNG HỢP 3: `message` là một chuỗi đơn giản
          _errorMessage = messageValue;
        } else {
          _errorMessage = 'Lỗi không xác định từ máy chủ.';
        }
        // =================================================================

      } else {
        _errorMessage = 'Không thể kết nối đến máy chủ. Vui lòng thử lại.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}