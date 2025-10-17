import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';

import '../../services/login_firebase_service.dart';
import '../../services/login_service.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginService _loginService = LoginService();
  final FirebaseLoginService _firebaseLoginService = FirebaseLoginService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // --- Giữ nguyên hàm login bằng email/password ---
  Future<void> login(String email, String password, BuildContext context) async {
    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Vui lòng nhập đủ thông tin");
      return;
    }
    _setLoading(true);
    try {
      final token = await _loginService.login(email, password);
      if (token != null) {
        Fluttertoast.showToast(msg: "Đăng nhập thành công");
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // --- THÊM MỚI: Hàm đăng nhập với Google ---
  Future<void> loginWithGoogle(BuildContext context) async {
    _setLoading(true);
    try {
      // 1. Đăng nhập Firebase
      final User? firebaseUser = await _firebaseLoginService.signInWithGoogle();

      if (firebaseUser != null) {
        // 2. Lấy Firebase ID token
        final idToken = await firebaseUser.getIdToken();
        if (idToken == null) throw Exception("Không thể lấy Firebase ID Token.");

        // 3. Gửi ID token qua header để xác thực ở backend
        final profile = await _loginService.getFirebaseProfile(idToken);

        Fluttertoast.showToast(msg: "Đăng nhập Google thành công!");
        print("User profile: $profile");

        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      _setLoading(false);
    }
  }



  Future<void> autoLogin(BuildContext context) async {
    // Ưu tiên kiểm tra token của hệ thống trước
    final token = await _loginService.tryAutoLogin();
    if (token != null) {
      print("Tự động đăng nhập bằng token hệ thống.");
      Navigator.pushReplacementNamed(context, '/home');
    }
    // Nếu không có, thử kiểm tra session Firebase
    else if (_firebaseLoginService.getCurrentUser() != null) {
      print("Phát hiện session Firebase. Đang lấy lại token hệ thống...");
      // Nếu có session Firebase, thử lấy lại token hệ thống
      // để các API call sau này vẫn hoạt động
      await loginWithGoogle(context);
    }
  }

  Future<void> logout(BuildContext context) async {
    await _loginService.logout();
    await _firebaseLoginService.signOut();
    Navigator.pushReplacementNamed(context, '/'); // Quay về màn hình login
  }
}