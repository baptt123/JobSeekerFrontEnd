import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../services/auth_service.dart';
import '../../utils/token_storage.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  String email = '';
  bool loading = false;

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  Future<void> resetPassword(BuildContext context) async {
    loading = true;
    notifyListeners();

    try {
      await AuthService().resetPassword(email);

      loading = false;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mật khẩu mới đã được gửi qua email")),
      );

      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      loading = false;
      notifyListeners();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
