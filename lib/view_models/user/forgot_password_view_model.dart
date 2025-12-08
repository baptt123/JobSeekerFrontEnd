// lib/view_models/user/forgot_password_view_model.dart

import 'package:flutter/material.dart';
import '../../dto/forgot_password_dto.dart';
import '../../services/forgot_password_service.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final ForgotPasswordService _service = ForgotPasswordService();
  final TextEditingController emailController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _successMessage;
  String? get successMessage => _successMessage;

  // Validate Email cơ bản ở Client
  bool get isValidEmail {
    final email = emailController.text.trim();
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Future<void> submitForgotPassword() async {
    // Reset trạng thái
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    // 1. Check validate Client
    if (!isValidEmail) {
      _errorMessage = "Vui lòng nhập đúng định dạng email.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // 2. Gọi API Backend
      final dto = ForgotPasswordDto(email: emailController.text.trim());

      // Nếu thành công, hàm này trả về message từ backend
      final message = await _service.forgotPassword(dto);

      // ✅ Hiển thị thông báo thành công (Màu xanh)
      _successMessage = message;
      emailController.clear(); // Xóa ô nhập để tránh spam

    } catch (e) {
      // ❌ Hiển thị thông báo lỗi (Màu đỏ) - Lỗi này lấy từ Service (VD: Email không tồn tại)
      _errorMessage = e.toString().replaceAll("Exception: ", "");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}