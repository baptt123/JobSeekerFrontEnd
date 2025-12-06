// lib/view_models/user/register_view_model.dart

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/dto/register_dto.dart';
import 'package:job_seeker_frontend/services/register_service.dart';

class RegisterViewModel extends ChangeNotifier {
  final RegisterService _registerService = RegisterService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSuccess => _isSuccess;

  // Sửa hàm register để trả về bool
  Future<bool> register({
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

      if (response.statusCode == 201 || response.statusCode == 200) {
        _isSuccess = true;
        _isLoading = false;
        notifyListeners();
        return true; // Đăng ký thành công
      }
    } on DioException catch (e) {
      if (e.response != null && e.response?.data is Map) {
        final responseData = e.response!.data as Map<String, dynamic>;
        final messageValue = responseData['message'];

        if (messageValue is Map) {
          _errorMessage = messageValue['message'] as String?;
        } else if (messageValue is List) {
          _errorMessage = messageValue.join('\n');
        } else if (messageValue is String) {
          _errorMessage = messageValue;
        } else {
          _errorMessage = 'Lỗi không xác định từ máy chủ.';
        }
      } else {
        _errorMessage = 'Không thể kết nối đến máy chủ. Vui lòng thử lại.';
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false; // Đăng ký thất bại
  }
}