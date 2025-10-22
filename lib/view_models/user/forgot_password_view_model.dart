// viewmodels/forgot_password_viewmodel.dart

import 'package:flutter/material.dart';
import 'package:job_seeker_frontend/services/forgot_password_service.dart';
import '../../dto/forgot_password_dto.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final ForgotPasswordService _authService = ForgotPasswordService();

  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // ... (các hàm _setLoading, _setErrorMessage, _setSuccessMessage không đổi)

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _setSuccessMessage(String? message) {
    _successMessage = message;
    notifyListeners();
  }

  Future<void> submitForgotPassword() async {
    _setErrorMessage(null);
    _setSuccessMessage(null);

    if (formKey.currentState?.validate() ?? false) {
      _setLoading(true);
      try {
        // 2. Tạo đối tượng DTO từ dữ liệu trong controller
        final forgotPasswordDto = ForgotPasswordDto(
          email: emailController.text.trim(),
        );

        // 3. Gọi service với DTO vừa tạo
        final message = await _authService.forgotPassword(forgotPasswordDto);
        _setSuccessMessage(message);
      } catch (e) {
        _setErrorMessage(e.toString());
      } finally {
        _setLoading(false);
      }
    }
  }

  // ... (hàm validateEmail và dispose không đổi)
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập email của bạn.';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Vui lòng nhập một địa chỉ email hợp lệ.';
    }
    return null;
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}