import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:job_seeker_frontend/views/login/user/message_screen.dart';
import 'package:provider/provider.dart';

import '../../services/login_firebase_service.dart';
import '../../services/login_service.dart';
// Đảm bảo model UserToken đã được cập nhật để đọc { "user": { "id": ... } }
// như chúng ta đã làm ở bước trước.

class LoginViewModel extends ChangeNotifier {
  final LoginService _loginService = LoginService();
  final FirebaseLoginService _firebaseLoginService = FirebaseLoginService();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

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
      // 1. Đăng nhập và lấy token (đã bao gồm userId)
      final token = await _loginService.login(email, password);

      if (token != null) {
        Fluttertoast.showToast(msg: "Đăng nhập thành công");

        // 2. Lấy ID của user vừa đăng nhập
        final int currentUserId = token.userId;
        print("Đăng nhập thành công với User ID: $currentUserId");
        // Chúng ta không cần if/else ở đây nữa.

        // 3. ✅ ĐIỀU HƯỚNG VỀ TRANG CHỦ
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // --- HÀM LOGIN VỚI GOOGLE (Giữ nguyên) ---
  // (Tôi giữ nguyên hàm này vì bạn chỉ cung cấp backend cho login email)
  Future<void> loginWithGoogle(BuildContext context) async {
    _setLoading(true);
    try {
      final User? firebaseUser = await _firebaseLoginService.signInWithGoogle();
      if (firebaseUser != null) {
        final idToken = await firebaseUser.getIdToken();
        if (idToken == null) throw Exception("Không thể lấy Firebase ID Token.");
        final profile = await _loginService.getFirebaseProfile(idToken);
        Fluttertoast.showToast(msg: "Đăng nhập Google thành công!");
        print("User profile: $profile");

        // ❗️ Logic Google login của bạn CẦN ĐƯỢC CẬP NHẬT TƯƠNG TỰ
        // Bạn cần sửa backend cho Google login để trả về token
        // và UserID giống như login bằng email

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const MessageScreen(
              otherUserId: 2,
              otherUserName: 'Dianne Russell',
              otherUserAvatar: 'https://i.pravatar.cc/150?img=1',
            ),
          ),
        );
      }
    } catch (e) {
      Fluttertoast.showToast(msg: e.toString());
    } finally {
      _setLoading(false);
    }
  }


  // --- Các hàm autoLogin và logout (Giữ nguyên) ---
  Future<void> autoLogin(BuildContext context) async {
    final token = await _loginService.tryAutoLogin();
    if (token != null) {
      print("Tự động đăng nhập bằng token hệ thống.");

      // ❗️ BẠN CŨNG CẦN SỬA LOGIC NÀY
      // Bạn nên lấy userId từ `token.userId` (đã lưu trong storage)
      // và quyết định chuyển hướng về /home hay vào màn hình chat

      Navigator.pushReplacementNamed(context, '/home');
    }
    else if (_firebaseLoginService.getCurrentUser() != null) {
      print("Phát hiện session Firebase. Đang lấy lại token hệ thống...");
      await loginWithGoogle(context);
    }
  }

  Future<void> logout(BuildContext context) async {
    await _loginService.logout();
    await _firebaseLoginService.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }
}