import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseLoginService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Khởi tạo GoogleSignIn. Cú pháp này là chính xác.
  // Nếu IDE của bạn báo lỗi ở đây, rất có thể đó là vấn đề về cache hoặc phiên bản package.
  // Hãy thử các bước gỡ rối ở dưới sau khi cập nhật file này.
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Lấy người dùng hiện tại từ Firebase SDK
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Hàm xử lý đăng nhập với Google
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Bắt đầu quá trình đăng nhập Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      // Nếu người dùng hủy, trả về null
      if (googleUser == null) {
        return null;
      }

      // 2. Lấy thông tin xác thực (idToken, accessToken)
      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      // 3. Tạo credential cho Firebase
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Đăng nhập vào Firebase với credential
      final UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      // Trả về đối tượng User của Firebase
      return userCredential.user;
    } catch (e) {
      print("Lỗi khi đăng nhập Google: $e");
      // Ném lại lỗi để ViewModel có thể bắt và hiển thị cho người dùng
      throw Exception("Đăng nhập với Google thất bại. Vui lòng thử lại.");
    }
  }

  /// Hàm đăng xuất khỏi cả Google và Firebase
  Future<void> signOut() async {
    // Đảm bảo đăng xuất khỏi Google để có thể chọn lại tài khoản ở lần đăng nhập sau
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}
