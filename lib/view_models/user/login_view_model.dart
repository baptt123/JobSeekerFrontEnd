import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/login_service.dart';
import '../../services/login_firebase_service.dart';
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

  // --- 1. LOGIN BẰNG EMAIL ---
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
      final UserToken? tokenObject = await _loginService.login(email, password);

      if (tokenObject != null) {
        _userToken = tokenObject.accessToken;
        _userId = tokenObject.userId;
        notifyListeners();

        Fluttertoast.showToast(msg: "Đăng nhập thành công");

        // ✅ SỬA: Xóa hết stack cũ, set Home làm root
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString().replaceAll("Exception: ", ""));
    } finally {
      _setLoading(false);
    }
  }

  // --- 2. AUTO LOGIN (Tự động đăng nhập) ---
  Future<void> autoLogin(BuildContext context) async {
    print("🔄 Bắt đầu Auto Login...");

    // A. Thử login bằng Token hệ thống
    final UserToken? internalToken = await _loginService.tryAutoLogin();

    if (internalToken != null) {
      _userToken = internalToken.accessToken;
      _userId = internalToken.userId;
      notifyListeners();
      print("✅ Auto login bằng Token hệ thống thành công");

      // ✅ SỬA: Xóa hết stack cũ, vào thẳng Home
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      return;
    }

    // B. Nếu thất bại, thử login bằng Firebase (Google)
    print("⚠️ Token hệ thống hết hạn, thử Firebase...");
    final String? firebaseToken = await _firebaseLoginService.getFirebaseTokenSilently();

    if (firebaseToken != null) {
      try {
        await _handleBackendLogin(firebaseToken, context);
        print("✅ Auto login bằng Firebase thành công");
      } catch (e) {
        print("❌ Auto login Firebase thất bại: $e");
        await _loginService.logout();
      }
    } else {
      print("❌ Không có phiên đăng nhập. User cần login thủ công.");
      await _loginService.logout();
      // Không cần navigate vì người dùng đang ở LoginScreen rồi
    }
  }

  // --- 3. ĐĂNG XUẤT ---
  Future<void> logout(BuildContext context) async {
    await _loginService.logout();
    await _firebaseLoginService.signOut();
    _userToken = null;
    _userId = null;
    notifyListeners();

    // Về màn hình Login và xóa hết lịch sử
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  // --- 4. LOGIN VỚI GOOGLE ---
  Future<void> loginWithGoogle(BuildContext context) async {
    _setLoading(true);
    try {
      final String? firebaseToken = await _firebaseLoginService.signInWithGoogle();

      if (firebaseToken != null) {
        await _handleBackendLogin(firebaseToken, context);
      } else {
        Fluttertoast.showToast(msg: "Đã hủy đăng nhập Google");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Helper xử lý login với backend sau khi có token firebase
  Future<void> _handleBackendLogin(
      String firebaseToken,
      BuildContext context,
      ) async {
    try {
      final UserToken? tokenObject = await _firebaseLoginService.loginWithGoogleToken(firebaseToken);

      if (tokenObject != null) {
        Fluttertoast.showToast(msg: "Đăng nhập thành công");

        _userToken = tokenObject.accessToken;
        _userId = tokenObject.userId;
        notifyListeners();

        // ✅ SỬA: Xóa hết stack cũ, set Home làm root
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
      await _firebaseLoginService.signOut();
    }
  }
}