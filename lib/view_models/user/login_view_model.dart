import 'package:flutter/material.dart';

class LoginViewModel extends ChangeNotifier {
  String _email = '';
  String _password = '';
  bool _showPassword = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  String get email => _email;
  String get password => _password;
  bool get showPassword => _showPassword;
  bool get rememberMe => _rememberMe;
  bool get isLoading => _isLoading;

  void setEmail(String value) {
    _email = value;
    notifyListeners();
  }

  void setPassword(String value) {
    _password = value;
    notifyListeners();
  }

  void toggleShowPassword() {
    _showPassword = !_showPassword;
    notifyListeners();
  }

  void toggleRememberMe() {
    _rememberMe = !_rememberMe;
    notifyListeners();
  }

  Future<void> login() async {
    _isLoading = true;
    notifyListeners();
    // TODO: Call service to login
    await Future.delayed(const Duration(seconds: 2));
    _isLoading = false;
    notifyListeners();
  }

  Future<void> signInWithGoogle() async {
    // TODO: Implement google login
  }
}
