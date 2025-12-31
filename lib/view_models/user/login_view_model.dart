import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../services/login_service.dart';
import '../../services/login_firebase_service.dart';
import '../../models/user-token-entity.dart';
import '../../services/firebase_messaging_service.dart';
import '../../services/user_service.dart';

class LoginViewModel extends ChangeNotifier {
  final LoginService _loginService = LoginService();
  final FirebaseLoginService _firebaseLoginService = FirebaseLoginService();
  final FirebaseMessagingService _messagingService = FirebaseMessagingService();
  final UserService _userService = UserService();

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

  /// 🔥 Luồng thiết lập thông báo: Kích hoạt ép buộc hỏi quyền
  Future<void> _setupNotificationFlow(BuildContext context, int userId) async {
    // 1. Khởi tạo listener cho tin nhắn foreground
    _messagingService.initNotificationListeners((message) {
      print("🔔 Foreground message received.");
    });

    // 2. Ép buộc hiện Dialog hỏi quyền (hệ thống hoặc custom)
    await _messagingService.forceRequestPermission(context);

    // 3. Đăng ký nhận tin nhắn Chat riêng
    await _messagingService.subscribeToUserTopic(userId);
  }

  // --- 1. LOGIN BẰNG EMAIL ---
  Future<void> login(String email, String password, BuildContext context) async {
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

        // Kích hoạt hỏi quyền sau khi đăng nhập
        if (_userId != null && context.mounted) {
          await _setupNotificationFlow(context, _userId!);
        }

        Fluttertoast.showToast(msg: "Đăng nhập thành công");
        if (context.mounted) {
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      }
    } catch (e) {
      _handleLoginError(e, context);
    } finally {
      _setLoading(false);
    }
  }

  // --- 2. AUTO LOGIN ---
  Future<void> autoLogin(BuildContext context) async {
    final UserToken? internalToken = await _loginService.tryAutoLogin();

    if (internalToken != null) {
      _userToken = internalToken.accessToken;
      _userId = internalToken.userId;
      notifyListeners();

      // Kích hoạt hỏi quyền sau khi tự động đăng nhập
      if (_userId != null && context.mounted) {
        await _setupNotificationFlow(context, _userId!);
      }

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
      }
      return;
    }

    // Xử lý Google Auto-login...
    final String? firebaseToken = await _firebaseLoginService.getFirebaseTokenSilently();
    if (firebaseToken != null) {
      try {
        final UserToken? tokenObject = await _firebaseLoginService.loginWithGoogleToken(firebaseToken);
        if (tokenObject != null) {
          _userToken = tokenObject.accessToken;
          _userId = tokenObject.userId;
          notifyListeners();

          if (_userId != null && context.mounted) {
            await _setupNotificationFlow(context, _userId!);
          }

          if (context.mounted) Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (_) {
        await _loginService.logout();
      }
    }
  }

  // --- 3. ĐĂNG XUẤT ---
  Future<void> logout(BuildContext context) async {
    _setLoading(true);
    try {
      if (_userId != null) {
        // Hủy đăng ký topic và xóa token trên server
        await _messagingService.unsubscribeFromUserTopic(_userId!);
        await _userService.updateFcmToken(null);
      }

      await _loginService.logout();
      await _firebaseLoginService.signOut();
      _userToken = null;
      _userId = null;
      notifyListeners();

      if (context.mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } finally {
      _setLoading(false);
    }
  }

  // --- 4. LOGIN VỚI GOOGLE ---
  Future<void> loginWithGoogle(BuildContext context) async {
    _setLoading(true);
    try {
      final String? firebaseToken = await _firebaseLoginService.signInWithGoogle();
      if (firebaseToken != null) {
        final UserToken? tokenObject = await _firebaseLoginService.loginWithGoogleToken(firebaseToken);
        if (tokenObject != null) {
          _userToken = tokenObject.accessToken;
          _userId = tokenObject.userId;
          notifyListeners();

          if (_userId != null && context.mounted) {
            await _setupNotificationFlow(context, _userId!);
          }

          if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      }
    } catch (e) {
      _handleLoginError(e, context);
    } finally {
      _setLoading(false);
    }
  }

  void _handleLoginError(dynamic e, BuildContext context) {
    String errorMsg = e.toString().replaceAll("Exception: ", "");
    Fluttertoast.showToast(msg: errorMsg, backgroundColor: Colors.red);
  }
}