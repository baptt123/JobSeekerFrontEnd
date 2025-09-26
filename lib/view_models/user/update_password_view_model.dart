import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../dto/change_password_dto.dart';
import '../../services/auth_service.dart';
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
    final dto = ChangePasswordDTO(
      oldPassword: oldPass,
      newPassword: newPass,
      confirmPassword: confirmPass,
    );

    try {
      await AuthService().updatePassword(dto);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đổi mật khẩu thành công, vui lòng đăng nhập lại")),
      );

      Navigator.of(context).pushReplacementNamed('/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}
