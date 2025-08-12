// view_models/forgot_password_view_model.dart
import 'package:flutter/material.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  String email = '';
  bool loading = false;

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  Future<void> resetPassword() async {
    loading = true;
    notifyListeners();
    // Giả lập delay
    await Future.delayed(const Duration(seconds: 2));
    loading = false;
    notifyListeners();
    // Xử lý reset password thực tế tại đây
  }
}
