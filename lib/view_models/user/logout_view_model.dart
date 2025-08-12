// lib/view_models/logout_view_model.dart
import 'package:flutter/material.dart';

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

  void logout() {
    // Xử lý logout ở đây
    dialogVisible = false;
    notifyListeners();
  }
}
