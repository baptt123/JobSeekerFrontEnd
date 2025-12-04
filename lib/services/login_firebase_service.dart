import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user-token-entity.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart'; // ✅ Đảm bảo import DioClient

class FirebaseLoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Sử dụng DioClient để có cấu hình chuẩn (timeout, base url)
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/auth');

  // --- 1. HÀM ĐĂNG NHẬP GOOGLE & LẤY ID TOKEN ---
  Future<String?> signInWithGoogle() async {
    try {
      // Trigger flow chọn tài khoản Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Người dùng hủy

      // Lấy thông tin xác thực từ Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Tạo credential
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Đăng nhập vào Firebase
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception("Không lấy được user từ Firebase");
      }

      // Lấy ID Token string để gửi về backend
      return await userCredential.user!.getIdToken();
    } catch (e) {
      print("Lỗi Google Sign In: $e");
      return null;
    }
  }

  // --- 2. HÀM LẤY TOKEN THẦM LẶNG (CHO AUTO LOGIN) ---
  Future<String?> getFirebaseTokenSilently() async {
    User? user = _auth.currentUser;
    if (user == null) return null;
    try {
      // forceRefresh = true để đảm bảo token còn hạn
      return await user.getIdToken(true);
    } catch (e) {
      print("Lỗi lấy token thầm lặng: $e");
      return null;
    }
  }

  // --- 3. HÀM ĐĂNG XUẤT ---
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (e) {
      print("Lỗi đăng xuất Firebase: $e");
    }
  }

  // --- 4. GỬI TOKEN LÊN BACKEND ĐỂ LẤY JWT HỆ THỐNG ---
  Future<UserToken> loginWithGoogleToken(String firebaseToken) async {
    try {
      String? deviceToken;
      try {
        deviceToken = await _firebaseMessaging.getToken();
      } catch (_) {} // Bỏ qua nếu lỗi lấy device token

      final response = await _dio.post(
        '/firebase-login',
        options: Options(
          // Token này gửi ở Header để Guard của NestJS bắt được
          headers: {'Authorization': 'Bearer $firebaseToken'},
        ),
        data: {
          "deviceToken": deviceToken,
        },
      );

      final userToken = UserToken.fromJson(response.data);
      await _saveTokens(userToken);
      return userToken;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _saveTokens(UserToken token) async {
    await _storage.write(key: 'accessToken', value: token.accessToken);
    await _storage.write(key: 'refreshToken', value: token.refreshToken);
    await _storage.write(key: 'userId', value: token.userId.toString());
  }
}