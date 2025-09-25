import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../utils/token_storage.dart';

class UpdatePasswordViewModel extends ChangeNotifier {
  bool oldObscure = true;
  bool newObscure = true;
  bool confirmObscure = true;

  void toggleOldObscure() {
    oldObscure = !oldObscure;
    notifyListeners();
  }

  void toggleNewObscure() {
    newObscure = !newObscure;
    notifyListeners();
  }

  void toggleConfirmObscure() {
    confirmObscure = !confirmObscure;
    notifyListeners();
  }

  Future<void> updatePassword(
      BuildContext context, String oldPass, String newPass, String confirmPass) async {
    final token = await TokenStorage.getAccessToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn chưa đăng nhập")),
      );
      return;
    }

    final url = Uri.parse("http://localhost:3000/auth/update-password");

    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "oldPassword": oldPass,
          "newPassword": newPass,
          "confirmPassword": confirmPass,
        }),
      );

      if (response.statusCode == 200) {
        // xoá token local
        await TokenStorage.clearTokens();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đổi mật khẩu thành công, vui lòng đăng nhập lại")),
        );

        // chuyển về màn login
        Navigator.of(context).pushReplacementNamed('/login');
      } else {
        final err = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err['message'] ?? 'Đổi mật khẩu thất bại')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi kết nối: $e")),
      );
    }
  }
}
