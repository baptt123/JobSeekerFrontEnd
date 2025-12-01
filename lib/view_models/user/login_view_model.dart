// lib/view_models/user/login_view_model.dart

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../../services/login_service.dart';
import '../../services/login_firebase_service.dart'; // Giữ lại nếu bạn vẫn dùng Google Login
import '../../models/user-token-entity.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginService _loginService = LoginService();
  final FirebaseLoginService _firebaseLoginService = FirebaseLoginService();

  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _userToken;
  int? _userId;

  String? get userToken => _userToken;

  int? get userId => _userId;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // 1. LOGIN THƯỜNG
  Future<void> login(
    String email,
    String password,
    BuildContext context,
  ) async {
    if (email.isEmpty || password.isEmpty) {
      Fluttertoast.showToast(msg: "Vui lòng nhập đủ thông tin");
      return;
    }
    _setLoading(true);
    try {
      // Gọi service login
      final UserToken? tokenObject = await _loginService.login(email, password);

      if (tokenObject != null) {
        _userToken = tokenObject.accessToken;
        _userId = tokenObject.userId;
        notifyListeners();

        Fluttertoast.showToast(msg: "Đăng nhập thành công");
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      // Hiển thị lỗi từ Service ném ra (VD: Sai pass, không tìm thấy user)
      Fluttertoast.showToast(msg: e.toString().replaceAll("Exception: ", ""));
    } finally {
      _setLoading(false);
    }
  }

  // [SỬA ĐỔI] Logic Auto Login thông minh hơn
  Future<void> autoLogin(BuildContext context) async {
    print("🔄 Bắt đầu Auto Login...");

    // BƯỚC 1: Thử login bằng Token hệ thống (NestJS Token) đang lưu
    // (Logic cũ của bạn trong _loginService.tryAutoLogin() vẫn tốt để dùng lại)
    final UserToken? internalToken = await _loginService.tryAutoLogin();

    if (internalToken != null) {
      _userToken = internalToken.accessToken;
      _userId = internalToken.userId;
      notifyListeners();
      print("✅ Auto login bằng Token hệ thống thành công");
      Navigator.pushReplacementNamed(context, '/home');
      return;
    }

    // BƯỚC 2: Nếu Token hệ thống hỏng/hết hạn, check phiên đăng nhập Google/Firebase
    print("⚠️ Token hệ thống hết hạn, thử đăng nhập lại bằng Firebase...");
    final String? firebaseToken = await _firebaseLoginService.getFirebaseTokenSilently();

    if (firebaseToken != null) {
      try {
        // Gọi lại backend để lấy Token hệ thống mới (đồng thời update Device Token luôn)
        await _handleBackendLogin(firebaseToken, context);
        // _handleBackendLogin đã bao gồm việc navigate sang Home
        print("✅ Auto login bằng Firebase session thành công");
      } catch (e) {
        print("❌ Auto login Firebase thất bại: $e");
        // Ở lại màn hình login
      }
    } else {
      print("❌ Không có phiên đăng nhập nào. Người dùng cần login thủ công.");
    }
  }

  // ... (Giữ nguyên logic logout và loginWithGoogle cũ của bạn) ...
  Future<void> logout(BuildContext context) async {
    await _loginService.logout();
    await _firebaseLoginService.signOut();
    _userToken = null;
    _userId = null;
    notifyListeners();
    Navigator.pushReplacementNamed(
      context,
      '/',
    ); // Đảm bảo route '/' là LoginScreen
  }

  // --- HÀM LOGIN VỚI GOOGLE (ĐÃ SỬA) ---
  Future<void> loginWithGoogle(BuildContext context) async {
    _setLoading(true);
    try {
      // 1. Lấy Firebase ID Token từ FirebaseLoginService
      final String? firebaseToken = await _firebaseLoginService
          .signInWithGoogle();

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

  /// [VIẾT LẠI] Hàm xử lý chung sau khi có Firebase Token
  /// (Dùng cho cả đăng nhập mới và tự động đăng nhập)
  Future<void> _handleBackendLogin(
    String firebaseToken,
    BuildContext context,
  ) async {
    try {
      // 2. Gửi Firebase Token lên backend để lấy JWT hệ thống
      final UserToken? tokenObject = await _firebaseLoginService
          .loginWithGoogleToken(firebaseToken);

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
