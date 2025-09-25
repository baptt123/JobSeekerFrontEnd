import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

    final url = Uri.parse("http://localhost:3000/auth/forgot-password");

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email}),
      );

      loading = false;
      notifyListeners();

      if (response.statusCode == 200) {
        // xoá token local (nếu có)
        await TokenStorage.clearTokens();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Mật khẩu mới đã được gửi qua email")),
        );

        // chuyển về màn login
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        final err = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err['message'] ?? 'Lỗi reset mật khẩu')),
        );
      }
    } catch (e) {
      loading = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi kết nối: $e")),
      );
    }
  }
}
