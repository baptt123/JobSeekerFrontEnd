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

// --- HÀM LOGIN VỚI GOOGLE (ĐÃ SỬA) ---
  Future<void> loginWithGoogle(BuildContext context) async {
    _setLoading(true);
    try {
      // 1. Lấy Firebase ID Token từ FirebaseLoginService
      final String? firebaseToken = await _firebaseLoginService.signInWithGoogle();

      if (firebaseToken != null) {
        // 2. Gọi hàm xử lý backend
        await _handleBackendLogin(firebaseToken, context);
      } else {
        // Người dùng đã hủy đăng nhập
        Fluttertoast.showToast(msg: "Đã hủy đăng nhập Google");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      _setLoading(false);
    }
  }


  // --- HÀM AUTOLOGIN (ĐÃ SỬA) ---
  Future<void> autoLogin(BuildContext context) async {
    // 1. Thử lấy token hệ thống (backend JWT) đã lưu
    final UserToken? tokenObject = await _loginService.tryAutoLogin();

    if (tokenObject != null) {
      print("Tự động đăng nhập bằng token hệ thống.");
      // 2. Lưu lại token và ID
      _userToken = tokenObject.accessToken;
      _userId = tokenObject.userId;
      notifyListeners();
      // 3. Điều hướng
      Navigator.pushReplacementNamed(context, '/home');
    }
    else {
      // 4. Nếu không có token hệ thống, kiểm tra session Firebase
      print("Không có token hệ thống. Kiểm tra session Firebase...");
      final String? firebaseToken = await _firebaseLoginService.getFirebaseTokenSilently();

      if (firebaseToken != null) {
        print("Phát hiện session Firebase. Đang lấy lại token hệ thống...");
        // 5. Nếu có session, dùng token đó để lấy JWT của backend
        // (Không cần setLoading(true) vì đây là auto-login, nên chạy ngầm)
        await _handleBackendLogin(firebaseToken, context);
      } else {
        print("Không có session nào. Người dùng cần đăng nhập.");
      }
    }
  }

  // --- HÀM LOGOUT (Giữ nguyên) ---
  Future<void> logout(BuildContext context) async {
    // ... (Giữ nguyên logic cũ của bạn) ...
    await _loginService.logout();
    await _firebaseLoginService.signOut();
    _userToken = null;
    _userId = null;
    notifyListeners();
    Navigator.pushReplacementNamed(context, '/');
  }
  /// [VIẾT LẠI] Hàm xử lý chung sau khi có Firebase Token
  /// (Dùng cho cả đăng nhập mới và tự động đăng nhập)
  Future<void> _handleBackendLogin(String firebaseToken, BuildContext context) async {
    try {
      // 2. Gửi Firebase Token lên backend để lấy JWT hệ thống
      final UserToken? tokenObject = await _firebaseLoginService.loginWithGoogleToken(firebaseToken);

      if (tokenObject != null) {
        Fluttertoast.showToast(msg: "Đăng nhập thành công");

        // 3. Lưu token backend và ID
        _userToken = tokenObject.accessToken;
        _userId = tokenObject.userId;
        notifyListeners();

        print("Đăng nhập Google thành công với User ID: $_userId");

        // 4. Điều hướng
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      // Nếu có lỗi, đảm bảo đăng xuất khỏi Firebase để tránh kẹt
      await _firebaseLoginService.signOut();
    }
  }

}