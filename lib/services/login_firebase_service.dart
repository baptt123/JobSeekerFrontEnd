import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user-token-entity.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart';

class FirebaseLoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/auth');

  // 1. Đăng nhập Google
  Future<String?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Người dùng hủy

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return await userCredential.user?.getIdToken();
    } catch (e) {
      print("Lỗi Google Sign In: $e");
      // Ném lỗi ra để ViewModel hiển thị Toast
      throw Exception(e.toString());
    }
  }

  // 2. Lấy token thầm lặng (dùng cho Auto Login)
  Future<String?> getFirebaseTokenSilently() async {
    User? user = _auth.currentUser;
    if (user == null) return null;
    try {
      return await user.getIdToken(true);
    } catch (e) {
      return null;
    }
  }

  // 3. Đăng xuất
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
    } catch (_) {}
  }

  // 4. Gửi token lên Backend
  Future<UserToken> loginWithGoogleToken(String firebaseToken) async {
    try {
      String? deviceToken;
      try {
        deviceToken = await _firebaseMessaging.getToken();
      } catch (_) {}

      final response = await _dio.post(
        '/firebase-login',
        options: Options(headers: {'Authorization': 'Bearer $firebaseToken'}),
        data: {"deviceToken": deviceToken},
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