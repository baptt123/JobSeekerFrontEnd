import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user-token-entity.dart';
import '../utils/constant_api.dart';
import '../utils/dio_client.dart'; // ✅ Import DioClient

class LoginService {
  // Sử dụng DioClient cho các request thông thường
  final Dio _dio = DioClient.getDio(baseUrl: '${ConstantAPI.baseUrl}/auth');
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 1. LOGIN
  Future<UserToken?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = UserToken.fromJson(response.data);
        await _saveTokens(token);
        return token;
      }
      return null;
    } on DioException catch (e) {
      final msg = e.response?.data['message'] ?? 'Đăng nhập thất bại';
      throw Exception(msg);
    }
  }

  // 2. AUTO LOGIN (CẬP NHẬT: Thêm Timeout và Xử lý lỗi mạng)
  Future<UserToken?> tryAutoLogin() async {
    final refreshToken = await _storage.read(key: 'refreshToken');
    if (refreshToken == null) return null;

    try {
      // ✅ CẬP NHẬT: Thiết lập timeout ngắn (ví dụ 5 giây)
      // Để nếu mạng lag hoặc server sập thì không bắt user đợi lâu
      final dio = Dio(BaseOptions(
        baseUrl: '${ConstantAPI.baseUrl}/auth',
        connectTimeout: const Duration(seconds: 5), // Quá 5s không kết nối được -> Hủy
        receiveTimeout: const Duration(seconds: 5), // Quá 5s không nhận được data -> Hủy
      ));

      final response = await dio.post(
        '/refresh',
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final token = UserToken.fromJson(response.data);
        await _saveTokens(token);
        return token;
      }
    } on DioException catch (e) {
      // ✅ XỬ LÝ THÔNG MINH:
      // - Nếu lỗi 400/401 (Token sai/hết hạn) -> Xóa token để đăng nhập lại
      if (e.response?.statusCode == 400 || e.response?.statusCode == 401) {
        await logout();
      }
      // - Nếu lỗi Mạng (Timeout, Server Die...) -> KHÔNG làm gì cả (Return null)
      //   App sẽ tự hiểu là không auto login được và chuyển người dùng vào màn hình chính (Guest Mode)
      //   mà không bị kẹt lại màn hình Splash.
      else {
        print("⚠️ Lỗi kết nối khi Auto Login: ${e.message}. Vào App với chế độ Khách/Offline.");
      }
    } catch (e) {
      // Lỗi khác không xác định -> Logout cho an toàn
      await logout();
    }
    return null;
  }

  Future<void> logout() async {
    await _storage.deleteAll();
  }

  Future<void> _saveTokens(UserToken token) async {
    await _storage.write(key: 'accessToken', value: token.accessToken);
    await _storage.write(key: 'refreshToken', value: token.refreshToken);
    await _storage.write(key: 'userId', value: token.userId.toString());
  }
}