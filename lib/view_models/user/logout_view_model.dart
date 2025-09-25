import 'package:flutter/material.dart';

import '../../utils/token_storage.dart';

class LogoutViewModel extends ChangeNotifier {
  bool dialogVisible = false;

  void showDialog() {
    dialogVisible = true;
    notifyListeners();
  }

  void hideDialog() {
    dialogVisible = false;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    // 1. Xoá token ở local storage
    await TokenStorage.clearTokens();

    // 2. Ẩn dialog
    dialogVisible = false;
    notifyListeners();

    // 3. Thông báo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Đăng xuất thành công!")),
    );

    // 4. Điều hướng về màn login
    Navigator.of(context).pushReplacementNamed('/login');
  }
}
