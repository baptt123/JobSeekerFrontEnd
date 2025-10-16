import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../services/login_service.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginService _authService = LoginService();
  bool isLoading = false;

  Future<void> login(String email, String password, BuildContext context) async {
    isLoading = true;
    notifyListeners();
    try {
      final token = await _authService.login(email, password);
      if (token != null) {
        Fluttertoast.showToast(msg: "Đăng nhập thành công");
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> autoLogin(BuildContext context) async {
    final token = await _authService.tryAutoLogin();
    if (token != null) {
      Fluttertoast.showToast(msg: "Tự động đăng nhập thành công");
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Fluttertoast.showToast(msg: "Phiên đăng nhập đã hết hạn, mời đăng nhập lại");
    }
  }
}
