import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/token_storage.dart';

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

  Future<void> login(BuildContext context) async {
    _isLoading = true;
    notifyListeners();
    try {
      final res = await AuthService.login(_email, _password);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Welcome back, ${res['user']['fullName']}!")),
      );
      // TODO: navigate to home screen
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Future<void> checkSession(BuildContext context) async {
  //   try {
  //     await AuthService.getProfile();
  //   } catch (e) {
  //     await TokenStorage.clearTokens();
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text(e.toString())),
  //     );
  //     // TODO: redirect to login
  //   }
  // }

  Future<void> signInWithGoogle() async {
    // TODO: Google sign-in
  }


}
