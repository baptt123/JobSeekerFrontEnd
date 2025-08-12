import 'package:flutter/material.dart';

class SignupViewModel extends ChangeNotifier {
  String fullName = "";
  String email = "";
  String password = "";
  bool rememberMe = false;
  bool isPasswordVisible = false;

  void setFullName(String value) {
    fullName = value;
    notifyListeners();
  }

  void setEmail(String value) {
    email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    password = value;
    notifyListeners();
  }

  void setRememberMe(bool? value) {
    rememberMe = value ?? false;
    notifyListeners();
  }

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    notifyListeners();
  }

  void signUp(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Sign up thành công!")),
    );
  }
}
