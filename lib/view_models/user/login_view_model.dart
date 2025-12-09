// lib/view_models/user/login_view_model.dart

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

        // Xóa hết stack cũ, set Home làm root
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      }
    } catch (e) {
      // 🔥 XỬ LÝ LỖI HIỂN THỊ
      String errorMsg = e.toString().replaceAll("Exception: ", "");

      // Kiểm tra nếu lỗi là 403 hoặc chứa từ khóa liên quan đến việc bị khóa
      if (errorMsg.contains("403") ||
          errorMsg.toLowerCase().contains("vô hiệu hóa") ||
          errorMsg.toLowerCase().contains("khóa")) {

        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false, // Bắt buộc người dùng phải bấm nút Đóng
            builder: (ctx) => AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.block, color: Colors.red),
                  SizedBox(width: 8),
                  Text("Tài khoản bị khóa", style: TextStyle(color: Colors.red)),
                ],
              ),
              content: const Text(
                "Tài khoản của bạn đã bị vô hiệu hóa do vi phạm chính sách hoặc yêu cầu từ quản trị viên.\n\nVui lòng liên hệ bộ phận hỗ trợ để biết thêm chi tiết.",
                style: TextStyle(fontSize: 15),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Đã hiểu", style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            ),
          );
        }
      } else {
        // Lỗi thông thường (sai pass, mạng...)
        Fluttertoast.showToast(
          msg: errorMsg,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
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

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
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
    }
  }

  // --- 3. ĐĂNG XUẤT ---
  Future<void> logout(BuildContext context) async {
    await _loginService.logout();
    await _firebaseLoginService.signOut();
    _userToken = null;
    _userId = null;
    notifyListeners();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
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

        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      }
    } catch (e) {
      // Xử lý lỗi cấm tài khoản cho Google Login
      if (e.toString().contains("403")) {
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text("Tài khoản bị khóa", style: TextStyle(color: Colors.red)),
              content: const Text("Tài khoản Google này đã bị khóa trên hệ thống."),
              actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Đóng"))],
            ),
          );
        }
      } else {
        Fluttertoast.showToast(msg: e.toString());
      }
      await _firebaseLoginService.signOut();
    }
  }
}