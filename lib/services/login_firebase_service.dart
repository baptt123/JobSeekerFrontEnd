import 'package:firebase_auth/firebase_auth.dart';
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

  /// Đăng nhập bằng Google Firebase Token
  Future<UserToken> loginWithGoogleToken(String firebaseToken) async {
    const String path = '/firebase-login';

    try {
      final response = await _dio.post(
        path,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $firebaseToken',
          },
        ),
      );

      // 3. Parse dữ liệu giống như style của bạn
      final userToken = UserToken.fromJson(response.data);

      // 4. Lưu vào FlutterSecureStorage (LƯU Ý: chỉ lưu String)
      await _storage.write(key: 'userToken', value: userToken.accessToken);
      await _storage.write(key: 'userId', value: userToken.userId.toString());

      return userToken;
    } on DioException catch (e) {
      // 5. Xử lý lỗi theo style của bạn: log và "rethrow"
      // Lớp gọi (ViewModel/Bloc) sẽ chịu trách nhiệm
      // bắt lỗi này và hiển thị thông báo cho người dùng.
      print('❌ Error logging in with Google: $e');
      rethrow;
    } catch (e) {
      // Bắt các lỗi khác (ví dụ: lỗi parsing .fromJson)
      print('❌ Error parsing token or saving to storage: $e');
      rethrow;
    }
  }
}
