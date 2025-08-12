// lib/view_models/update_password_view_model.dart
import 'package:flutter/material.dart';

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

  void updatePassword(String oldPass, String newPass, String confirmPass) {
    // Xử lý đổi pass ở đây
  }
}
