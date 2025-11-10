//
// 📄 [SỬA ĐỔI] baptt123/jobseekerfrontend/JobSeekerFrontEnd-develop/lib/view_models/user/login_view_model.dart
//
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:job_seeker_frontend/views/login/user/message_screen.dart';
import 'package:provider/provider.dart';

import '../../services/login_firebase_service.dart';
import '../../services/login_service.dart';
import '../../models/user-token-entity.dart'; // 👈 Cần import model này

class LoginViewModel extends ChangeNotifier {
  final LoginService _loginService = LoginService();
  final FirebaseLoginService _firebaseLoginService = FirebaseLoginService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ✅ [THÊM MỚI] Biến lưu trữ trạng thái
  String? _userToken; // Lưu chuỗi JWT
  int? _userId;

  // ✅ [THÊM MỚI] Getters để các View khác có thể đọc
  String? get userToken => _userToken;
  int? get userId => _userId;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // --- HÀM LOGIN BẰNG EMAIL/PASSWORD (ĐÃ SỬA) ---
  Future<void> login(String email, String password, BuildContext context) async {
    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Vui lòng nhập đủ thông tin");
      return;
    }
    _setLoading(true);
    try {
      // 1. Đăng nhập và lấy token (đổi tên biến cho rõ)
      final UserToken? tokenObject = await _loginService.login(email, password);

      if (tokenObject != null) {
        Fluttertoast.showToast(msg: "Đăng nhập thành công");

        // 2. ✅ LƯU TOKEN VÀ ID VÀO VIEWMODEL
        _userToken = tokenObject.accessToken; // Giả sử model có .token
        _userId = tokenObject.userId;
        notifyListeners(); // 👈 Báo cho các listener (như NotificationScreen)

        print("Đăng nhập thành công với User ID: $_userId");

        // 3. ĐIỀU HƯỚNG VỀ TRANG CHỦ
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // --- HÀM LOGIN VỚI GOOGLE (Tạm giữ nguyên) ---
  Future<void> loginWithGoogle(BuildContext context) async {
    // ... (Giữ nguyên logic cũ của bạn)
    // Tương tự, nếu thành công, bạn cũng nên gọi:
    // _userToken = ...
    // _userId = ...
    // notifyListeners();
  }


  // --- HÀM AUTOLOGIN (ĐÃ SỬA) ---
  Future<void> autoLogin(BuildContext context) async {
    // 1. Thử lấy token đã lưu từ service
    final UserToken? tokenObject = await _loginService.tryAutoLogin();

    if (tokenObject != null) {
      print("Tự động đăng nhập bằng token hệ thống.");

      // 2. ✅ LƯU LẠI TOKEN VÀ ID
      _userToken = tokenObject.accessToken; // Giả sử model có .token
      _userId = tokenObject.userId;
      notifyListeners(); // 👈 Báo cho app biết

      // 3. Điều hướng
      Navigator.pushReplacementNamed(context, '/home');
    }
    else if (_firebaseLoginService.getCurrentUser() != null) {
      print("Phát hiện session Firebase. Đang lấy lại token hệ thống...");
      // (Flow Google login của bạn)
      await loginWithGoogle(context);
    }
  }

  // --- HÀM LOGOUT (ĐÃ SỬA) ---
  Future<void> logout(BuildContext context) async {
    await _loginService.logout();
    await _firebaseLoginService.signOut();

    // ✅ XOÁ TOKEN VÀ ID KHI ĐĂNG XUẤT
    _userToken = null;
    _userId = null;
    notifyListeners(); // 👈 Báo cho app biết

    Navigator.pushReplacementNamed(context, '/');
  }
}