import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user-token-entity.dart';
import '../utils/constant_api.dart';

class FirebaseLoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final Dio _dio = Dio(BaseOptions(baseUrl: ConstantAPI.baseUrl + '/auth'));
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance; // [THÊM]
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// [SỬA ĐỔI] Trả về String? (Firebase ID Token) thay vì User?
  /// Hàm này sẽ hiển thị popup đăng nhập của Google nếu cần.
  Future<String?> signInWithGoogle() async {
    try {
      // 1. Bắt đầu quá trình đăng nhập Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // Người dùng hủy

      // 2. Lấy thông tin xác thực
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // 3. Tạo credential cho Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Đăng nhập vào Firebase SDK
      final UserCredential userCredential = await _auth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw Exception("Không lấy được thông tin người dùng từ Firebase.");
      }

      // 5. [QUAN TRỌNG] Lấy ID Token của Firebase và trả về
      final String? idToken = await userCredential.user!.getIdToken();
      return idToken;
    } catch (e) {
      print("Lỗi khi đăng nhập Google: $e");
      throw Exception("Đăng nhập với Google thất bại. Vui lòng thử lại.");
    }
  }

  /// [THÊM MỚI] Lấy token một cách âm thầm cho autoLogin
  /// Sẽ không hiển thị popup, chỉ lấy token nếu người dùng đã đăng nhập.
  Future<String?> getFirebaseTokenSilently() async {
    final User? user = getCurrentUser();
    if (user == null) {
      return null;
    }
    try {
      // Lấy token mới (forceRefresh = true) để đảm bảo token luôn hợp lệ
      final String? idToken = await user.getIdToken(true);
      return idToken;
    } catch (e) {
      print("Lỗi khi lấy token thầm lặng: $e");
      return null;
    }
  }

  /// Hàm đăng xuất
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  /// [SỬA ĐỔI] Đăng nhập backend kèm Device Token
  Future<UserToken> loginWithGoogleToken(String firebaseToken) async {
    const String path = '/firebase-login';

    try {
      // 1. [THÊM MỚI] Lấy Device Token (FCM Token)
      // Lưu ý: Cần xin quyền thông báo ở main.dart hoặc lúc khởi chạy app trước đó
      String? deviceToken;
      try {
        deviceToken = await _firebaseMessaging.getToken();
        print("📲 FCM Device Token: $deviceToken");
      } catch (e) {
        print("⚠️ Không lấy được Device Token: $e");
      }

      // 2. Gọi API NestJS
      final response = await _dio.post(
        path,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $firebaseToken', // Gửi ID Token ở Header
          },
        ),
        data: {
          // [THÊM MỚI] Gửi Device Token ở Body
          "deviceToken": deviceToken,
        },
      );

      final userToken = UserToken.fromJson(response.data);

      await _storage.write(key: 'userToken', value: userToken.accessToken);
      await _storage.write(key: 'userId', value: userToken.userId.toString());
      // Lưu refresh token để dùng sau này nếu cần
      if (response.data['refreshToken'] != null) {
        await _storage.write(
          key: 'refreshToken',
          value: response.data['refreshToken'],
        );
      }

      return userToken;
    } on DioException catch (e) {
      print('❌ Error logging in with Google: $e');
      rethrow;
    } catch (e) {
      print('❌ Error parsing token: $e');
      rethrow;
    }
  }
}
